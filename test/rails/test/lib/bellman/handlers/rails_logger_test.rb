# frozen_string_literal: true

require 'test_helper'

module Bellman
  module Handlers
    class RailsLoggerTest < ActiveSupport::TestCase
      def test_does_handle_message
        handler = Bellman::Handlers::RailsLogger.new

        Bellman.config.severities.each do |severity|
          assert_log_includes("#{severity.to_s.upcase} | message") do
            handler.handle('message', severity:)
          end
        end
      end

      def test_does_handle_errors
        handler = Bellman::Handlers::RailsLogger.new
        error = StandardError.new('message')

        Bellman.config.severities.each do |severity|
          assert_log_includes("#{severity.to_s.upcase} | message") do
            handler.handle(error, severity:)
          end
        end
      end
    end
  end
end
