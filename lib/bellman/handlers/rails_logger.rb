# frozen_string_literal: true

module Bellman
  module Handlers
    # Handle Rails logging
    class RailsLogger < BaseHandler
      def initialize(logger: nil)
        super()
        @logger = logger
      end

      # rubocop:disable Metrics/ParameterLists
      def handle(
        error, severity: nil, trace_id: nil, objects: nil, data: nil,
        include_backtrace: false
      )
        logger.send(
          severity,
          build_message(
            error, severity:, trace_id:, objects:, data:, include_backtrace:
          )
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def logger
        @logger || Rails.logger
      end

      private

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/PerceivedComplexity
      def build_message(
        error, severity: nil, trace_id: nil, data: nil, objects: nil,
        include_backtrace: false
      )
        str = severity_to_s(severity)
        str = "#{str} | TRACE_ID[#{trace_id}]" if trace_id

        unless error.nil?
          str = if error.respond_to?(:message)
                  "#{str} | #{error.message}"
                else
                  "#{str} | #{error}"
                end
        end
        str = "#{str} | #{objects_to_s(objects)}" if objects
        str = "#{str} | DATA[#{data.to_json}]" if data
        if !error.nil? && include_backtrace && error.respond_to?(:backtrace)
          str = "#{str} | #{error.backtrace}"
        end
        str
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/PerceivedComplexity

      def severity_to_s(severity)
        Bellman.config.default_severity.to_s.upcase.to_s unless severity

        severity.to_s.upcase.to_s
      end

      def objects_to_s(objects)
        "OBJECTS#{objects.map do |object|
                    "#{object.class.name}|#{object.id}"
                  end}"
      end
    end
  end
end
