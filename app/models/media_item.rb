class MediaItem < Forest::ApplicationRecord
  include BaseMediaItem

  scope :by_title, -> { order(title: :asc, id: :asc) }
end
