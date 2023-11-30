# frozen_string_literal: true

require 'test_helper'

module Bellman
  module Handlers
    class SentryTest < ActiveSupport::TestCase
      def setup
        require_relative '../../../../config/initializers/sentry'
      end

      def test_does_handle_string_error
        sentry_mock = Minitest::Mock.new
        sentry_mock.expect :call, nil, ['message']

        ::Sentry.stub(:capture_message, sentry_mock) do
          handler = Sentry.new
          handler.handle('message')
        end

        sentry_mock.verify
      end

      def test_does_handle_errors
        error = StandardError.new('message')

        sentry_mock = Minitest::Mock.new
        sentry_mock.expect :call, nil, [error]

        ::Sentry.stub(:capture_exception, sentry_mock) do
          handler = Bellman::Handlers::Sentry.new
          handler.handle(error)
        end

        sentry_mock.verify
      end
    end
  end
end
