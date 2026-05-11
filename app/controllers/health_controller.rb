class HealthController < ApplicationController
  def show
    skip_authorization
    head :ok
  end
end
