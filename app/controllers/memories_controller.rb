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
    if params[:shared] == true && params[:id] == @memory.shared_link
      skip_authorization
    else
      authorize @memory
    end

    if current_user.try(:admin?)
      @media_items = @memory.media_items
    else
      @media_items = @memory.media_items.visible_to_public
      @page_title = @memory.public_title.presence || @memory.title
    end
  end

  private

    def set_memory
      if params[:shared] == true
        @memory = Memory.find_by!(shared_link: params[:id])
      else
        @memory = Memory.find_by!(slug: params[:id])
      end
    end
end
