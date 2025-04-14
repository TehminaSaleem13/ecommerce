# config/initializers/image_processing.rb

require 'image_processing/mini_magick'

# Set a safe temp directory (no spaces!)
MiniMagick.configure do |config|
  config.tmpdir = Rails.root.join("tmp", "mini_magick").to_s
end
