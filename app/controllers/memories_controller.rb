class MemoriesController < ForestController
  include Pagy::Backend

  before_action :set_memory, only: [:show]

  def index
    if current_user && current_user.admin?
      @pagy, @memories = pagy apply_scopes(Memory.published.by_date)
    else
      @pagy, @memories = pagy apply_scopes(Memory.published.public_only.by_date)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    authorize @memory
  end

  private

    def set_memory
      @memory = Memory.find_by!(slug: params[:id])
    end
end
