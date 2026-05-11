require 'exifr/jpeg'

FileUploader.class_eval do
  # https://shrinerb.com/docs/plugins/add_metadata
  forest_store_upload_options = opts.dig(:upload_options, :store)

  plugin :upload_options, store: -> (file, options) do
    upload_options =
      if forest_store_upload_options.respond_to?(:call)
        forest_store_upload_options.call(file, options)
      else
        forest_store_upload_options || {}
      end

    upload_options.merge(acl: 'public-read')
  end

  add_metadata do |io, derivative: nil, **|
    begin
      if derivative.nil? && io.image? && (io.content_type == 'image/jpeg')
        exif_data = Shrine.with_file(io) do |file|
          EXIFR::JPEG.new(file.path)
        end

        exif_data.to_hash
      end
    rescue => e
      Rails.logger.error { e.message }
      Rails.logger.error { e.backtrace.first(10).join("\n") }

      {}
    end
  end
end
