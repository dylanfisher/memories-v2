class ScreensaverController < ForestController
  layout 'screensaver'

  def index
    pattern = /^\d{4}-\d{2}-\d{2}$/
    from = params[:from]&.match(pattern)
    to = params[:to]&.match(pattern)

    if from.blank? && to.blank?
      offset = rand(MediaItem.count)
      @media_item = MediaItem.all.offset(offset).first
    else
      memories = Memory.all

      if from.present?
        from_date = Date.parse(from[0])
        memories = memories.from_date(from_date)
      end

      if to.present?
        to_date = Date.parse(to[0])
        memories = memories.to_date(to_date)
      end

      # binding.pry

      media_item_range = memories.collect(&:parsed_media_item_range)
      media_item_skip_range = memories.collect(&:parsed_media_item_skip_range).reject { |x| x == 0 }

      media_item_scope = MediaItem.where(id: media_item_range)
                                  .where.not(id: media_item_skip_range)

      offset = rand(media_item_scope.count)
      @media_item = media_item_scope.offset(offset).first
    end
  end
end
