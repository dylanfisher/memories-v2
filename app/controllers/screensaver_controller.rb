class ScreensaverController < ForestController
  layout 'screensaver'

  def index
    @media_item = MediaItem.order('RANDOM()').first
  end
end
