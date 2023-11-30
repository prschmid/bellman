# frozen_string_literal: true

module Bellman
  module Handlers
    # Base class for all error handlers
    class BaseHandler
      # rubocop:disable Lint/UnusedMethodArgument
      # rubocop:disable Metrics/ParameterLists
      def handle(
        _error, severity: nil, trace_id: nil, objects: nil, data: nil,
        include_backtrace: false
      )
        raise 'Not implemented'
      end
      # rubocop:enable Lint/UnusedMethodArgument
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
