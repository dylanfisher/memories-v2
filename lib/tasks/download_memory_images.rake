require 'digest'
require 'fileutils'
require 'json'
require 'open-uri'
require 'thread'
require 'uri'

namespace :memories do
  desc 'Interactively download full resolution images for recent public memories'
  task download_images: :environment do
    limit = (ENV['LIMIT'].presence || 25).to_i
    limit = 25 if limit <= 0
    thread_count = (ENV['DOWNLOAD_THREADS'].presence || 8).to_i
    thread_count = 8 if thread_count <= 0
    endpoint_base = select_endpoint_base

    memories = fetch_recent_memories(endpoint_base, limit)

    if memories.blank?
      puts 'No published public memories found.'
      next
    end

    puts "Recent published public memories:"
    memories.each_with_index do |memory, index|
      puts format('%<index>2d. [%<id>d] %<date>s  %<title>s',
                  index: index + 1,
                  id: memory_id(memory),
                  date: memory_date(memory),
                  title: memory_title(memory))
    end

    print "\nChoose memories to download (for example: 1,3,5-7 or all): "
    selected_memories = select_memories(memories, STDIN.gets)

    if selected_memories.blank?
      puts 'No memories selected.'
      next
    end

    print 'Orientation filter (all, portrait, landscape) [landscape]: '
    orientation = normalize_orientation(STDIN.gets)

    print 'Download location [/Volumes/main-1/photos/public]: '
    destination_root = STDIN.gets.to_s.strip.presence || '/Volumes/main-1/photos/public'

    if destination_root.blank?
      puts 'No download location provided.'
      next
    end

    destination_root = File.expand_path(destination_root)
    FileUtils.mkdir_p(destination_root)

    selected_memories.each do |memory|
      api_memory = fetch_memory_urls(memory_id(memory), endpoint_base, orientation)
      images = images_from_api_memory(api_memory)

      folder_name = "#{folder_title(memory)}-#{memory_id(memory)}"
      memory_destination = File.join(destination_root, folder_name)
      FileUtils.mkdir_p(memory_destination)

      manifest_path = File.join(memory_destination, '.downloaded_media_items.json')
      manifest = read_manifest(manifest_path)

      puts "\n#{memory_title(memory)} (#{images.length} images)"
      download_image_urls(images, memory_destination, manifest, thread_count)

      write_manifest(manifest_path, manifest)
    rescue OpenURI::HTTPError => e
      puts "\n#{memory_title(memory)}: failed to fetch URLs from #{endpoint_base} (#{e.message})"
    rescue JSON::ParserError => e
      puts "\n#{memory_title(memory)}: endpoint returned invalid JSON (#{e.message})"
    end
  end
end

def images_from_api_memory(api_memory)
  images = Array(api_memory['images']).filter_map do |image|
    url = image['url'] || image[:url]
    next if url.blank?

    {
      url: url,
      filename: image['filename'] || image[:filename]
    }
  end

  images = Array(api_memory['image_urls']).filter_map { |url| { url: url } } if images.blank?
  images.uniq { |image| image[:url] }
end

def select_endpoint_base
  endpoint = ENV['ENDPOINT'].presence || ENV['API_ENDPOINT'].presence
  return normalize_endpoint_base(endpoint) if endpoint.present?

  print 'API endpoint (local, production, or custom URL) [production]: '
  input = STDIN.gets.to_s.strip
  normalize_endpoint_base(input.presence || 'production')
end

def normalize_endpoint_base(value)
  endpoint = value.to_s.strip

  case endpoint.downcase
  when 'local'
    ENV['LOCAL_ENDPOINT'].presence || 'http://localhost:3000'
  when 'production', 'prod', 'remote'
    'https://photos.dylanfisher.com'
  else
    endpoint = 'https://photos.dylanfisher.com' if endpoint.blank?
    endpoint = "https://#{endpoint}" unless endpoint.match?(%r{\Ahttps?://}i)
    endpoint.sub(%r{/*\z}, '')
  end
end

def fetch_memory_urls(memory_id, endpoint_base, orientation)
  uri = URI.parse("#{endpoint_base}/api/memories/#{memory_id}/urls")
  query = {}
  query[:orientation] = orientation if orientation.present?
  uri.query = URI.encode_www_form(query) if query.present?

  JSON.parse(URI.open(uri.to_s, read_timeout: 120, open_timeout: 120).read)
end

def fetch_recent_memories(endpoint_base, limit)
  uri = URI.parse("#{endpoint_base}/api/memories/recent")
  uri.query = URI.encode_www_form(limit: limit)

  JSON.parse(URI.open(uri.to_s, read_timeout: 120, open_timeout: 120).read)
rescue OpenURI::HTTPError => e
  puts "Failed to fetch recent memories from #{endpoint_base} (#{e.message})"
  []
rescue JSON::ParserError => e
  puts "Recent memories endpoint returned invalid JSON (#{e.message})"
  []
end

def select_memories(memories, input)
  input = input.to_s.strip.downcase
  return memories if input == 'all'

  indexes = input.split(',').flat_map do |part|
    if part.include?('-')
      start_index, end_index = part.split('-', 2).map { |value| value.strip.to_i }
      (start_index..end_index).to_a
    else
      part.to_i
    end
  end

  indexes.uniq.filter_map { |index| memories[index - 1] }
end

def normalize_orientation(input)
  orientation = input.to_s.strip.downcase
  return :landscape if orientation.blank?
  return nil if orientation == 'all'
  return :portrait if orientation == 'portrait'
  return :landscape if ['landscape', 'horizontal'].include?(orientation)

  puts "Unknown orientation '#{orientation}', downloading all images."
  nil
end

def folder_title(memory)
  safe_filename(memory_title(memory))
end

def memory_id(memory)
  memory['id'] || memory[:id]
end

def memory_date(memory)
  memory['date'] || memory[:date]
end

def memory_title(memory)
  memory['title'] || memory[:title]
end

def safe_filename(value)
  value.to_s
       .strip
       .gsub(/[\/\\?%*:|"<>]/, '-')
       .gsub(/\s+/, ' ')
       .presence || 'untitled'
end

def read_manifest(path)
  return {} unless File.exist?(path)

  JSON.parse(File.read(path))
rescue JSON::ParserError
  {}
end

def write_manifest(path, manifest)
  File.write(path, JSON.pretty_generate(manifest.sort.to_h))
end

def download_image_urls(images, destination, manifest, thread_count)
  queue = Queue.new
  images.each_with_index { |image, index| queue << image.merge(index: index) }

  manifest_mutex = Mutex.new
  output_mutex = Mutex.new
  paths_in_progress = []
  worker_count = [thread_count, images.length].min

  output_mutex.synchronize { puts "  downloading with #{worker_count} threads" } if worker_count.positive?

  Array.new(worker_count) do
    Thread.new do
      loop do
        image = queue.pop(true)
        download_image_url(image, destination, manifest, manifest_mutex, paths_in_progress, output_mutex)
      rescue ThreadError
        break
      end
    end
  end.each(&:join)
end

def download_image_url(image, destination, manifest, manifest_mutex, paths_in_progress, output_mutex)
  url = image[:url]
  index = image[:index]
  manifest_key = Digest::SHA256.hexdigest(url)
  path = nil

  manifest_mutex.synchronize do
    if manifest[manifest_key].present?
      existing_path = File.join(destination, manifest[manifest_key]['filename'].to_s)
      if File.exist?(existing_path)
        output_mutex.synchronize { puts "  skipped #{File.basename(existing_path)} (already downloaded)" }
        return
      end
    end

    filename = safe_filename(image[:filename].presence || filename_for(url, index))
    target_path = File.join(destination, filename)

    if File.exist?(target_path)
      manifest[manifest_key] = {
        'filename' => File.basename(target_path),
        'url_digest' => Digest::SHA256.hexdigest(url),
        'downloaded_at' => Time.current.iso8601
      }
      output_mutex.synchronize { puts "  skipped #{File.basename(target_path)} (already exists)" }
      return
    end

    path = unique_path(target_path, manifest_key.first(8), paths_in_progress)
    paths_in_progress << path
  end

  partial_path = "#{path}.part-#{Process.pid}-#{Thread.current.object_id}"

  URI.open(url, read_timeout: 120, open_timeout: 120) do |remote_file|
    File.open(partial_path, 'wb') do |local_file|
      IO.copy_stream(remote_file, local_file)
    end
  end

  FileUtils.mv(partial_path, path)

  manifest_mutex.synchronize do
    manifest[manifest_key] = {
      'filename' => File.basename(path),
      'url_digest' => Digest::SHA256.hexdigest(url),
      'downloaded_at' => Time.current.iso8601
    }
    paths_in_progress.delete(path)
  end

  output_mutex.synchronize { puts "  downloaded #{File.basename(path)}" }
rescue => e
  FileUtils.rm_f(partial_path) if defined?(partial_path) && partial_path.present?
  manifest_mutex.synchronize { paths_in_progress.delete(path) } if path.present?
  output_mutex.synchronize { puts "  failed #{url}: #{e.class} - #{e.message}" }
end

def filename_for(url, index)
  uri_path = URI.parse(url).path
  filename = File.basename(uri_path.to_s)
  filename = "image-#{index + 1}" if filename.blank? || filename == '/'

  safe_filename(filename)
rescue URI::InvalidURIError
  "image-#{index + 1}"
end

def unique_path(path, suffix, reserved_paths = [])
  return path unless File.exist?(path) || reserved_paths.include?(path)

  directory = File.dirname(path)
  extension = File.extname(path)
  basename = File.basename(path, extension)
  candidate = File.join(directory, "#{basename}-#{suffix}#{extension}")
  index = 2

  while File.exist?(candidate) || reserved_paths.include?(candidate)
    candidate = File.join(directory, "#{basename}-#{suffix}-#{index}#{extension}")
    index += 1
  end

  candidate
end
