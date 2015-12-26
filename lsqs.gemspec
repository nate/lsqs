# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lsqs/version'

Gem::Specification.new do |gem|
  gem.name          = 'lsqs'
  gem.version       = LSQS::VERSION
  gem.authors       = ['giannismelidis']
  gem.email         = ['gmelidis@engineer.com']
  gem.summary       = 'Gem that allows you to run a version of SQS server locally.'
  gem.description   = gem.summary
  gem.homepage      = 'http://github.com/giannismelidis/lsqs'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ['lib', 'config']
  
  gem.add_dependency 'liquid'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'puma'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'builder'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'aws-sdk'
  gem.add_development_dependency 'webmock'
end
