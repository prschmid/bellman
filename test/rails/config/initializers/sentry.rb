# frozen_string_literal: true

Sentry.init do |config|
  # Set the Sentry Datat Source Name so that it goes to the right place
  # at Sentry.io
  config.dsn = Rails.nil? ? nil : Rails.application.credentials.sentry_dsn

  # Sentry has it's own threadpool of async workers that by default is set to
  # the number of processors that are available. If you want to send events
  # synchronously, set the value to 0. If you want to use the default number,
  # comment out this line
  config.background_worker_threads = 5

  # Sentry supports different breadcrumbs loggers in the Ruby SDK:
  #   sentry_logger: A general breadcrumbs logger for all Ruby applications.
  #   active_support_logger: Built on top of ActiveSupport instrumentation and
  #                          provides many Rails-specific information.
  #   monotonic_active_support_logger: Similar to :active_support_logger but
  #                                    breadcrumbs will have monotonic time
  #                                    values. Only available with Rails 6.1+.
  #   http_logger: It captures requests made with the standard net/http library.
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # As of v0.10.0, events will be sent to Sentry in all environments. If you
  # do not wish to send events in an environment, we suggest you unset
  # the SENTRY_DSN variable in that environment. Alternately, you can configure
  # Sentry to run only in certain environments by configuring the
  # enabled_environments list.
  config.enabled_environments = %w[development staging production]

  # Sentry automatically sets the current environment to RAILS_ENV, or if it
  # is not present, RACK_ENV. If you are using Sentry outside of Rack or Rails,
  # or wish to override environment detection, you'll need to set the current
  # environment by setting SENTRY_CURRENT_ENV or configuring the client
  # yourself.
  # config.environment = Rails.env

  # If you never wish to be notified of certain exceptions, specify
  # 'excluded_exceptions' in your config file.
  # config.excluded_exceptions += [
  #   'ActionController::RoutingError', 'ActiveRecord::RecordNotFound'
  # ]

  # The logger used by Sentry. Default is Rails.logger in Rails, otherwise an
  # instance of Sentry::Logger. Sentry respects logger levels.
  # config.logger = Sentry::Logger.new(STDOUT)

  # The maximum number of breadcrumbs the SDK would hold. Default is 100.
  # https://docs.sentry.io/product/issues/issue-details/breadcrumbs/
  config.max_breadcrumbs = 30

  # By default, Sentry injects sentry-trace header to outgoing requests made
  # with Net::HTTP to connect traces between services. You can disable this
  # behavior with
  # config.propagate_traces = false

  # The sampling factor to apply to events. A value of 0.00 will deny sending
  # any events, and a value of 1.00 will send 100% of events.
  # https://docs.sentry.io/platforms/ruby/configuration/sampling/
  config.sample_rate = if Rails.nil?
                         0.0
                       elsif Rails.env.production?
                         0.5
                       else
                         1.0
                       end

  # When its value is false (default), sensitive information like
  #   user ip, user cookie, request body, query string in the url
  # will not be sent to Sentry. You can re-enable it by setting:
  # config.send_default_pii = true

  # By providing a float between 0.0 and 1.0, you can control the sampling
  # factor of tracing events. Tracing is he process of logging the events that
  # took place during a request, often across multiple services. nil (default)
  # or 0.0 means the tracing feature is disabled. 1.0 means sending all the
  # events.
  config.traces_sample_rate = if Rails.nil?
                                0.0
                              elsif Rails.env.production?
                                0.5
                              else
                                1.0
                              end

  # You can gain more control on tracing event (transaction)'s sampling
  # decision by providing a callable object (Proc or Lambda) as a
  # traces_sampler. For an example see the documentation here:
  # https://docs.sentry.io/platforms/ruby/configuration/options/
  # config.traces_sampler = lambda do |sampling_context| ... end
end
