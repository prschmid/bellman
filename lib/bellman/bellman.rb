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
  # Config object to emulate ActiveSupport::Configurable behavior that is
  # deprecated in Rails 8.2
  class Config
    attr_accessor :severities, :default_severity, :on_unknown_severity,
                  :handlers

    def initialize
      @severities = %i[debug info warn error fatal].freeze
      @default_severity = :error
      @on_unknown_severity = :raise
      @handlers = [
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
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    # Set the defaults
    @config = Config.new
    
    # Yield to block if given
    yield(config) if block_given?

    # Create an instance of the handler that can be used
    @handler = Handlers::Handler.new
  end

  def self.handler(id: nil)
    if id.nil?
      @handler
    else
      @handler.handlers.find { |hndlr| hndlr[:id] == id.to_sym }
    end
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
