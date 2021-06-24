class Memory < Forest::ApplicationRecord
  include Blockable
  include Sluggable
  include Statusable

  validates :title, :date, presence: true

  scope :by_date, -> (orderer = :desc) { order(date: orderer) }

  def self.resource_description
    'Reflecting on the past.'
  end

  def media_items
    return MediaItem.none if media_item_range.blank?

    MediaItem.where(id: parse_range(media_item_range))
             .where.not(id: parse_range(media_item_skip_range))
             .by_title
  end

  # def media_items
  #   media_item_ids = []

  #   blocks.each do |b|
  #     media_item_ids.push(b.media_item_id) if b.try(:media_item_id).present?
  #     if b.try(:media_items_to_use).present?
  #       media_item_ids.concat(b.media_items_to_use.pluck(:id))
  #     elsif b.try(:media_item_ids).present?
  #       media_item_ids.concat(b.media_item_ids)
  #     end
  #   end

  #   if media_item_ids.present?
  #     MediaItem.where(id: media_item_ids.uniq)
  #   else
  #     MediaItem.none
  #   end
  # end

  private

  def parse_range(value)
    if value.to_s.include?(',')
      value.split(',').collect { |v| v.strip.to_i }
    elsif value.to_s.include?('-')
      range = value.split('-').collect { |v| v.strip.to_i }[0..1]
      (range[0]..range[1])
    else
      value.to_i
    end
  end
end
