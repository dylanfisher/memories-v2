module Api
  class MemoriesController < ::ForestController
    ORIENTATION_FILTERS = {
      'portrait' => :portrait?,
      'horizontal' => :landscape?,
      'landscape' => :landscape?
    }.freeze

    def recent
      skip_authorization

      limit = params[:limit].presence.to_i
      limit = 25 if limit <= 0

      memories = Memory.published.public_only.by_date.limit(limit)

      render json: memories.map { |memory| serialize_recent_memory(memory) }
    end

    def full_resolution_image_urls
      skip_authorization

      orientation_filter = params[:orientation].presence&.to_s&.downcase

      if orientation_filter.present? && ORIENTATION_FILTERS.exclude?(orientation_filter)
        render json: { error: 'orientation must be portrait or horizontal' }, status: :bad_request
        return
      end

      memory = Memory.published.public_only.by_date.find(params[:memory_id])

      render json: serialize_memory(memory, orientation_filter)
    end

    private

    def serialize_recent_memory(memory)
      {
        id: memory.id,
        slug: memory.slug,
        title: memory.public_title.presence || memory.title,
        date: memory.date
      }
    end

    def serialize_memory(memory, orientation_filter)
      images = images_for(memory, orientation_filter)

      {
        id: memory.id,
        slug: memory.slug,
        title: memory.public_title.presence || memory.title,
        date: memory.date,
        images: images.map { |media_item| serialize_image(media_item) },
        image_urls: images.map(&:attachment_url).compact
      }
    end

    def images_for(memory, orientation_filter)
      memory.media_items
            .visible_to_public
            .select(&:image?)
            .select { |media_item| include_for_orientation?(media_item, orientation_filter) }
    end

    def serialize_image(media_item)
      {
        id: media_item.id,
        url: media_item.attachment_url,
        filename: image_filename(media_item)
      }
    end

    def image_filename(media_item)
      filename = media_item.attachment_file_name.presence || File.basename(URI.parse(media_item.attachment_url).path)
      "#{media_item.id}-#{filename}"
    rescue URI::InvalidURIError
      "#{media_item.id}-image"
    end

    def include_for_orientation?(media_item, orientation_filter)
      return true if orientation_filter.blank?

      media_item.width.present? &&
        media_item.height.present? &&
        media_item.public_send(ORIENTATION_FILTERS.fetch(orientation_filter))
    end
  end
end
