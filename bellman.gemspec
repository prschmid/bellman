# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bellman/version'

Gem::Specification.new do |spec|
  spec.name = 'bellman'
  spec.version = Bellman::VERSION
  spec.authors       = ['Patrick R. Schmid']
  spec.email         = ['prschmid@gmail.com']

  spec.summary       = 'Unified way to take all of the log messages and direct them to the right place.'
  spec.description   = 'Unified way to take all of the log messages and direct them to the right place.'
  spec.homepage      = 'https://github.com/prschmid/bellman'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/prschmid/bellman'
    spec.metadata['changelog_uri'] = 'https://github.com/prschmid/bellman'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2'

  spec.add_runtime_dependency('activerecord', '> 4.2.0')
  spec.add_runtime_dependency('activesupport', '> 4.2.0')
  spec.metadata['rubygems_mfa_required'] = 'true'
end
