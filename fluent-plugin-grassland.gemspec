# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'fluent-plugin-grassland'
  spec.version       = '0.0.4'
  spec.authors       = ['Ripplation Inc.']
  # spec.email         = ['xxxxxx@ripplation.co.jp']
  spec.description   = 'Output filter plugin for Grassland'
  spec.summary       = 'Output filter plugin for Grassland'
  spec.homepage      = 'http://www.ripplation.co.jp'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'fluentd'
  spec.add_dependency 'eventmachine', '~> 1.0.3'
  spec.add_dependency 'aws-sdk', '~> 1.40.3'
  spec.add_dependency 'json'
  # spec.add_development_dependency 'bundler', '~> 1.3'
  # spec.add_development_dependency 'rake'
end
