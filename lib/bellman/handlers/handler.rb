# frozen_string_literal: true

module Bellman
  module Handlers
    # Main interface for interacting with all of the registerd handlers
    class Handler
      attr_reader :handlers

      def initialize(handlers: nil)
        handlers ||= Bellman.config.handlers
        @handlers = process_handlers_config(handlers)
      end

      # rubocop:disable Metrics/ParameterLists
      def handle(error, severity: :error, trace_id: nil, objects: nil,
                 data: nil, include_backtrace: false, handlers: nil)
        severity = handle_severity(severity)
        handlers = if handlers.present?
                     process_handlers_config(handlers)
                   else
                     @handlers
                   end

        handled = false
        handlers.each do |handler|
          next unless handler[:severities].include?(severity)

          raise "No handler specificed in #{handler}" unless handler[:handler]

          handler[:handler].handle(
            error, severity:, trace_id:, objects:, data:, include_backtrace:
          )

          handled = true
        end

        handled
      end
      # rubocop:enable Metrics/ParameterLists

      private

      def handle_severity(severity)
        return severity if Bellman.config.severities.include?(severity)
        if Bellman.config.on_unknown_severity != :raise
          return Bellman.config.default_severity
        end

        raise "Unknown severity level #{severity}. " \
              "Must be one of #{Bellman.config.severities}"
      end

      def process_handlers_config(configs)
        configs.map { |config| process_handler_config(config) }
      end

      def process_handler_config(config)
        config = to_handler_config(config) unless config.is_a?(Hash)

        initalize_from_config_hash(config)
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/PerceivedComplexity
      def initalize_from_config_hash(config)
        if config[:handler]
          config[:class] = config[:handler].class
        elsif config[:class]
          if config[:class].is_a?(String)
            config[:class] = config[:class].safe_constantize
          end
          config[:handler] = if config[:params].blank?
                               config[:class].new
                             else
                               config[:class].new(**config[:params])
                             end
        elsif config[:id]
          config = Bellman.handler(config[:id])
          config[:handler] = if config[:params].blank?
                               config[:class].new
                             else
                               config[:class].new(**config[:params])
                             end
        else
          raise "Bellman: Could not initialize handler from config: #{config}"
        end
        config
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/PerceivedComplexity

      # rubocop:disable Metrics/CyclomaticComplexity
      def to_handler_config(config)
        retval = { severities: Bellman.config.severities }

        case config
        when Symbol
          handler = Bellman.handler(id: config)
          return handler if handler
        when String
          # If the string matches the ID of a handler defined in the Bellman
          # default config, return that.
          handler = Bellman.handler(id: config.to_sym)
          return handler if handler

          # rubocop:disable Lint/SuppressedException
          begin
            retval[:class] = config.safe_constantize
          rescue StandardError
          end
          # rubocop:enable Lint/SuppressedException
        when Class
          retval[:class] = config
        when BaseHandler
          retval[:class] = config.class
        else
          raise 'Bellman: Unsupported handler. Handlers ' \
                'must be an array of strings, classes, ' \
                'or instances of Bellman::BaseHandler: ' \
                "#{config}"
        end

        retval
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
