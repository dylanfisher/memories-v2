class MemoriesController < ForestController
  include Pagy::Backend

  before_action :set_memory, only: [:show]

  def index
    @page_title = 'Home'

    if current_user && current_user.admin?
      @pagy, @memories = pagy apply_scopes(Memory.published.by_date), items: 1000
    else
      @pagy, @memories = pagy apply_scopes(Memory.published.public_only.by_date), items: 1000
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    authorize @memory

    if current_user.try(:admin?)
      @media_items = @memory.media_items
    else
      @media_items = @memory.media_items.visible_to_public
      @page_title = @memory.public_title.presence || @memory.title
    end
  end

  private

    def set_memory
      @memory = Memory.find_by!(slug: params[:id])
    end
end
