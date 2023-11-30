# frozen_string_literal: true

# Bellman
#
# Unified way to take all of the log messages and direct them to the right
# place.
#
# By default all messages will be logged using the Rails standard logger and
# any message with severity of :error or :fatal will also be sent to
# Sentry.
#
#
# For historical details on a bellman/town crier see:
#   https://en.wikipedia.org/wiki/Town_crier
module Bellman
  include ActiveSupport::Configurable

  def self.configure
    # Set the defaults
    config.severities = %i[debug info warn error fatal].freeze
    config.default_severity = :error
    config.handlers = [
      {
        id: :log,
        class: Bellman::Handlers::RailsLogger,
        severities: %i[debug info warn error fatal]
      },
      {
        id: :sentry,
        class: Bellman::Handlers::Sentry,
        severities: %i[error fatal]
      }
    ]

    super

    # Create an instance of the handler that can be used
    @handler = Handlers::Handler.new
  end

  def self.handler
    @handler
  end

  def self.error_handler(id:)
    @handler.handlers.find { |hndlr| hndlr[:id] == id.to_sym }
  end

  # rubocop:disable Metrics/ParameterLists
  def self.handle(
    error, severity: nil, trace_id: nil, objects: nil, data: nil,
    include_backtrace: false, handlers: nil
  )
    @handler.handle(
      error, severity:, trace_id:, objects:, data:, include_backtrace:,
             handlers:
    )
  end
  # rubocop:enable Metrics/ParameterLists
end
