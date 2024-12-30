class ScreensaverController < ForestController
  layout 'screensaver'

  def index
    memories = Memory.public_only

    pattern = /^\d{4}-\d{2}-\d{2}$/
    from = params[:from]&.match(pattern)
    to = params[:to]&.match(pattern)

    # ?from=2023-01-01
    if from.present?
      from_date = Date.parse(from[0])
      memories = memories.from_date(from_date)
    end

    # ?to=2023-12-31
    if to.present?
      to_date = Date.parse(to[0])
      memories = memories.to_date(to_date)
    end

    media_item_range = memories.collect(&:parsed_media_item_range)
    media_item_skip_range = memories.collect(&:parsed_media_item_skip_range).reject { |x| x == 0 }

    media_item_scope = MediaItem.where(id: media_item_range)
                                .where.not(id: media_item_skip_range)
                                .visible_to_public

    @media_item = media_item_scope.order('RANDOM()').first
  end
end
