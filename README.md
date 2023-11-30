# Bellman

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/prschmid/bellman/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/prschmid/bellman/tree/main)
[![Gem Version](https://badge.fury.io/rb/bellman.svg)](https://badge.fury.io/rb/bellman)

A simple and unified way to send log messages to the right place.

Why is this gem called Bellman? For historical details on a [bellman/town crier](https://en.wikipedia.org/wiki/Town_crier).

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add bellman

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install bellman

## Usage

Simply replace any call to a logger with

```ruby
# Use the default severity
Bellman.handle('Log this error message')

# Set the severity
Bellman.handle('Log this info message', severity: info)
```

And then based on your configuration this message will be sent to the right place. By default the severity level for a message is set to `:error`, but that can easily be configured or overridden on a case by case basis.

### Including Data

In many cases you will want to add some extra data to your log messages. The log messages are formatted in such a way that it should be easy to pull the extra information out with regular expressions, etc. 

You can add arbitrary data to the log message as follows:

```ruby
Bellman.handle(
    'Something you should know about',
    severity: :info,
    data: {
        favorite_food: 'Ice Cream'
    }
)
```

This will result in a message that looks like

```sh
INFO | Something you should know about | DATA[{"favorite_food":"Ice Cream"}]
```

If there is a case where you want to add some objects to this log message, you can do this by passing them in.

```ruby
project = Project.last
task = project.tasks.last

Bellman.handle(
    'Something you should know about',
    severity: :info,
    objecst: [project, task]
)
```

Assuming you are using UUIDs, this will result in a message that will look something like

```sh
INFO | Something you should know about | OBJECTS["Project|6a491e9d-ceb7-41fd-97ef-6cd8a6460242", "Task|ab30e8c7-eabf-4c95-ba97-a523bf017093"]
```

## Configuration

The aim of `bellman` is to take the guesswork out of where to send the logs and have it be configured in a uniform way for an entire application. 

For example, here is a common configuration for when an application uses the Rails logger to send all logs to a centralized logging store (e.g. Papertrail, Sumo Logic, etc.) and then sends only the "high severity" ones to Sentry.io.

```ruby
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
```

If for some reason you want to pass parameters to a handler while it is being initialized (e.g. if you make your own custom handler) you can do this by passing in `params` as follows:

```ruby
Bellman.configure do |config|
  config.default_severity = :error
  config.handlers = [
      {
        id: :custom_handler,
        class: Acme::Handlers::CustomHandler,
        params: {
            some_option: 'foo',
            other_option: 'bar'
        },
        severities: %i[debug info warn error fatal]
      }
    ]
end
```

## Handlers

### Predefined Handlers

Built-in are 2 pre-defined handlers for handling log message

* `Bellman::Handlers::RailsLogger`: Send the log message to the Rails logger
* `Bellman::Handlers::Sentry`: Send the log message to Sentry.io

## Custom Handlers

Need a specific handler that's not built in? One can easily create a new log handler by simply inheriting from `Bellman::BaseHandler` and implementing the one method

```ruby
def handle(
    error, severity: nil, trace_id: nil, objects: nil, data: nil,
    include_backtrace: false
)
    raise 'Not implemented'
end
```

Once that is created, go ahead and add it to the configuration (see above).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/prschmid/bellman.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
