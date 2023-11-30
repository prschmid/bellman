# frozen_string_literal: true

module Bellman
  module Handlers
    # Handle Sentry logging
    class Sentry < BaseHandler
      OBJECT_KEYS = [:profile_id, 'profile_id'].freeze

      def initialize(sentry: nil)
        super()
        @sentry = sentry
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/PerceivedComplexity
      def handle(
        error, severity: nil, trace_id: nil, objects: nil, data: nil, **
      )
        sentry.with_scope do |scope|
          scope.set_level(severity)
          set_sentry_context(scope, objects) if objects.present?

          if trace_id
            data ||= {}
            data[:trace_id] = trace_id
          end

          set_sentry_user_and_tags(scope, data) if data.present?

          error = '[EMPTY MESSAGE]' if error.nil?
          if error.respond_to?(:message) && error.respond_to?(:backtrace)
            sentry.capture_exception(error)
          else
            sentry.capture_message(error.to_s)
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/PerceivedComplexity

      def sentry
        @sentry || ::Sentry
      end

      private

      def set_sentry_context(scope, objects)
        # We are organizing the objects by class so that we can send the data
        # on a per class basis. Note, we cannot just loop over the objects
        # if we are using the class name as the key since this would mean that
        # any time there are multiple objects of the same type, we'd only send
        # the data for the last one as it would overwrite the data.
        h = {}
        objects.each do |object|
          key = object.class.name
          h[key] = [] unless h.key?(key)
          h[key] << object
        end

        h.each do |key, obj_array|
          scope.set_context(
            key, { ids: obj_array.map(&:id) }
          )
        end
      end

      def set_sentry_user_and_tags(scope, data)
        data = data.with_indifferent_access
        scope.set_user(id: data[:profile_id]) if data[:profile_id]
        data.each do |key, val|
          next if OBJECT_KEYS.include? key

          scope.send(:set_tags, **{ key => val })
        end
      end
    end
  end
end
