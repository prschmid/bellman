# frozen_string_literal: true

require 'bellman/version'

directories = [
  File.join(File.dirname(__FILE__), 'bellman'),
  File.join(File.dirname(__FILE__), 'bellman', 'handlers')
]

directories.each do |directory|
  Dir[File.join(directory, '*.rb')].each do |file|
    require file
  end
end

ActiveRecord::Base.instance_eval { include Bellman }
if defined?(Rails) && Rails.version.to_i < 4
  raise 'This version of bellman requires Rails 4 or higher'
end
