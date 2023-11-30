# frozen_string_literal: true

# Configure Bellman
Bellman.configure do |config|
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
end
