# Force load the Logger class before ActiveSupport tries to use it
require 'logger'

# Monkey patch to ensure the constant is available
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger unless defined?(Logger)
  end
end