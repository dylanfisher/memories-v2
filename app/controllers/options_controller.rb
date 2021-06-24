class OptionsController < ApplicationController
  def full
    cookies[:full_width] = !view_context.full_width?

    return redirect_to(params[:redirect_to])
  end
end
