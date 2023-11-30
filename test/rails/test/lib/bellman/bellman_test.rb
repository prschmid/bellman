# frozen_string_literal: true

require 'test_helper'

class BellmanTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bellman::VERSION
  end

  def test_does_initialize_with_config_defaults
    assert_equal 2, Bellman.handler.handlers.count

    log_handler = Bellman.handler.handlers.first

    assert_equal :log, log_handler[:id]
    assert_equal Bellman::Handlers::RailsLogger, log_handler[:class]
    assert_equal %i[debug info warn error fatal], log_handler[:severities]

    sentry_handler = Bellman.handler.handlers.second

    assert_equal :sentry, sentry_handler[:id]
    assert_equal Bellman::Handlers::Sentry, sentry_handler[:class]
    assert_equal %i[error fatal], sentry_handler[:severities]
  end

  def test_can_get_handler_based_on_id
    assert_equal 2, Bellman.handler.handlers.count

    [
      [:log, Bellman::Handlers::RailsLogger],
      ['log', Bellman::Handlers::RailsLogger],
      [:sentry, Bellman::Handlers::Sentry],
      ['sentry', Bellman::Handlers::Sentry]
    ].each do |test_case|
      id = test_case[0]
      klass = test_case[1]

      handler = Bellman.error_handler(id:)

      assert_equal klass, handler[:class]
    end
  end
end
