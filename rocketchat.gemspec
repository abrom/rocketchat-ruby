# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'yard', '~> 0.8.7.6'
  spec.add_development_dependency 'rubocop', '~> 0.48.1'
end
