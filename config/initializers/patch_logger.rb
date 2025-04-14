# This patch needs to run before Rails loads
require 'logger'

# Force define the Logger constant in the ActiveSupport namespace
module ActiveSupport
  module LoggerThreadSafeLevel
    # Make sure Logger is defined before Rails tries to use it
    Logger = ::Logger unless defined?(Logger)
  end
end