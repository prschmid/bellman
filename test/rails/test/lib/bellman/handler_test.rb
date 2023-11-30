# frozen_string_literal: true

require 'test_helper'

module Bellman
  module Handlers
    class HandlerTest < ActiveSupport::TestCase
      def test_does_initialize_with_config_defaults
        handler = Bellman::Handlers::Handler.new

        assert_equal 2, handler.handlers.count

        log_handler = handler.handlers.first

        assert_equal :log, log_handler[:id]
        assert_equal Bellman::Handlers::RailsLogger, log_handler[:class]
        assert_equal %i[debug info warn error fatal], log_handler[:severities]

        sentry_handler = handler.handlers.second

        assert_equal :sentry, sentry_handler[:id]
        assert_equal Bellman::Handlers::Sentry, sentry_handler[:class]
        assert_equal %i[error fatal], sentry_handler[:severities]
      end

      def test_can_initialize_with_overriden_handlers_using_handler_class_name
        [
          'Bellman::Handlers::RailsLogger',
          'Bellman::Handlers::Sentry'
        ].each do |class_name|
          handler = Bellman::Handlers::Handler.new(handlers: [class_name])

          assert_equal 1, handler.handlers.count

          error_handler = handler.handlers.first

          assert_nil error_handler[:id]
          assert_equal class_name.safe_constantize, error_handler[:class]
          assert_equal error_handler[:handler].class.name, class_name
          assert_equal %i[debug info warn error fatal],
                       error_handler[:severities]
        end
      end

      def test_can_initialize_with_overriden_handlers_using_handler_class
        [
          Bellman::Handlers::RailsLogger,
          Bellman::Handlers::Sentry
        ].each do |klass|
          handler = Bellman::Handlers::Handler.new(handlers: [klass])

          assert_equal 1, handler.handlers.count

          error_handler = handler.handlers.first

          assert_nil error_handler[:id]
          assert_equal klass, error_handler[:class]
          assert_equal error_handler[:handler].class, klass
          assert_equal %i[debug info warn error fatal],
                       error_handler[:severities]
        end
      end

      def test_can_initialize_with_overriden_handlers_using_handler_id
        %i[log sentry].each do |id|
          handler = Bellman::Handlers::Handler.new(handlers: [id])

          assert_equal 1, handler.handlers.count

          error_handler = handler.handlers.first

          assert_equal id, error_handler[:id]
          assert_equal error_handler, Bellman.handler(id:)
        end
      end

      def test_only_uses_log_handler_for_lower_severity_calls_by_default
        %i[debug info warn].each do |severity|
          handler = Bellman::Handlers::Handler.new

          assert_equal \
            [
              Bellman::Handlers::RailsLogger,
              Bellman::Handlers::Sentry
            ],
            handler.handlers.pluck(:class)

          log_handler_mock = Minitest::Mock.new
          log_handler_mock.expect(
            :call,
            nil,
            ['message'],
            severity:, trace_id: nil, objects: nil, data: nil,
            include_backtrace: false
          )

          handler.handlers.first[:handler].stub(:handle, log_handler_mock) do
            handler.handle('message', severity:)
          end

          log_handler_mock.verify
        end
      end

      def test_uses_log_and_sentry_handler_for_higher_severity_calls_by_default
        %i[error fatal].each do |severity|
          handler = Bellman::Handlers::Handler.new

          assert_equal \
            [
              Bellman::Handlers::RailsLogger,
              Bellman::Handlers::Sentry
            ],
            handler.handlers.pluck(:class)

          log_handler_mock = Minitest::Mock.new
          log_handler_mock.expect(
            :call,
            nil,
            ['message'],
            severity:, trace_id: nil, objects: nil, data: nil,
            include_backtrace: false
          )

          sentry_handler_mock = Minitest::Mock.new
          sentry_handler_mock.expect(
            :call,
            nil,
            ['message'],
            severity:, trace_id: nil, objects: nil, data: nil,
            include_backtrace: false
          )

          handler.handlers.first[:handler].stub(:handle, log_handler_mock) do
            handler.handlers.second[:handler].stub(:handle,
                                                   sentry_handler_mock) do
              handler.handle('message', severity:)
            end
          end

          log_handler_mock.verify
          sentry_handler_mock.verify
        end
      end

      def test_does_raise_error_if_unknown_severity_is_used
        handler = Bellman::Handlers::Handler.new

        random_severity = 'RANDOM_SEVERITY_LEVEL'

        assert_not Bellman.config.severities.include?(random_severity)

        error = assert_raises(StandardError) do
          handler.handle('Should raise', severity: random_severity)
        end

        assert_equal \
          "Unknown severity level #{random_severity}. " \
          "Must be one of #{Bellman.config.severities}",
          error.message
      end
    end
  end
end
