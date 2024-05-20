class ApplicationController < ActionController::Base
  before_action :http_authenticate

  private

  def http_authenticate
    unless Rails.env.development?
      authenticate_or_request_with_http_basic do |username, password|
        username == 'dylan' && password == 'nostalgia'
      end
    end
  end
end
