class MemoriesController < ForestController
  before_action :set_memory, only: [:show]

  def index
    @memories = apply_scopes(Memory.published.by_date)
  end

  def show
    authorize @memory
  end

  private

    def set_memory
      @memory = Memory.find_by!(slug: params[:id])
    end
end
