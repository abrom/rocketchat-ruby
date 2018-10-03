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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|docs)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.57'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.28'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'yard', '~> 0.9.11'
end
