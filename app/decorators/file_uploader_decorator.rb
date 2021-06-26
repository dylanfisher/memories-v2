require 'exifr/jpeg'

FileUploader.class_eval do
  # https://shrinerb.com/docs/plugins/add_metadata

  add_metadata do |io, derivative: nil, **|
    begin
      return unless derivative.nil? && io.image? && (io.content_type == 'image/jpeg')

      exif_data = Shrine.with_file(io) do |file|
        EXIFR::JPEG.new(file.path)
      end

      exif_data.to_hash
    rescue => e
      Rails.logger.error { e.message }
      Rails.logger.error { e.backtrace.first(10).join("\n") }

      {}
    end
  end
end
