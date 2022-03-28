# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rocket_chat/gem_version'

Gem::Specification.new do |spec|
  spec.name          = 'rocketchat'
  spec.version       = RocketChat::VERSION
  spec.authors       = %w[int512 abrom]
  spec.email         = %w[github@int512.net a.bromwich@gmail.com]

  spec.summary       = 'Rocket.Chat REST API v1 for Ruby'
  spec.description   = 'Rocket.Chat REST API v1 for Ruby'
  spec.homepage      = 'https://github.com/abrom/rocketchat-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = ['>= 2.5.0', '< 3.2.0']

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|docs)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', ['>= 1.11', '< 3.0']
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.12'
  spec.add_development_dependency 'rubocop-performance', '~> 1.10'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 3.12'
  spec.add_development_dependency 'yard', '~> 0.9.11'
end
