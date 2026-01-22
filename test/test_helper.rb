# frozen_string_literal: true

# Configure Rails Environment for the dummy testing Rails app
ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'minitest/mock'
require 'active_record'
require 'bellman'

# Include the dummy Rails app so we can run the tests for the components
# that require Rails
require File.expand_path('dummy/config/environment.rb', __dir__)

# We don't need to include this for now, but keeping this for now incase we
# need it in the future.
# require 'test/unit' # or possibly rspec/minispec

#
# Helper methods for testing
#

# Adapted from
# https://github.com/rails/rails/blob/82822a34217503336d51b7baab82cd18cf71e435/
#   actionpack/test/controller/live_stream_test.rb#L272
#
# log = capture_log_output do
#   Rails.logger.info("foo")
# end
# assert_match "foo", log
def capture_log_output
  output = StringIO.new
  old_logger = Rails.logger
  Rails.logger = ActiveSupport::Logger.new(output)

  begin
    yield
  ensure
    Rails.logger = old_logger
  end
  output.rewind && output.read
end

# assert_log_includes("foo") do
#   Rails.logger.info("foo")
# end
def assert_log_includes(value, &)
  captured_log = capture_log_output(&)

  assert_includes captured_log, value
end
