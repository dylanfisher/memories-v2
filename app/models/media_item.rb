class MediaItem < Forest::ApplicationRecord
  include BaseMediaItem

  scope :by_title, -> { order(title: :asc, id: :asc) }
  scope :hide_from_public, -> { where(hide_from_public: true) }
  scope :range, -> (range) {
    range_match = range.to_s.match(/(\d+)-(\d+)/)
    from = range_match[1].to_i
    to = range_match[2].to_i
    where('id > ? AND id < ?', from, to)
  }

  def self.additional_permitted_params
    [:hide_from_public]
  end
end
