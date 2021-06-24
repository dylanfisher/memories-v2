Forest.setup do |config|
  config.image_derivative_large_options[:resize][:width] = 3000
  config.image_derivative_large_options[:resize][:height] = 3000
  config.image_derivative_large_options[:jpeg][:quality] = 90
end
