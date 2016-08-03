# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'akamai_ccu/version'

Gem::Specification.new do |spec|
  spec.name          = 'akamai_ccu'
  spec.version       = AkamaiCCU::VERSION
  spec.authors       = ['Kasumi Hanazuki']
  spec.email         = ['kasumi@rollingapple.net']

  spec.summary       = 'Wrapepr for Akamai CCU API'
  spec.description   = 'Ruby wrapper for Akamai {OPEN} Content Control Utility (CCU) API v2'
  spec.homepage      = 'https://github.com/hanazuki/akamai_ccu'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split(?\0).reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'akamai-edgegrid', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-json_expectations', '~> 1.4'
  spec.add_development_dependency 'webmock', '~> 2.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
end
