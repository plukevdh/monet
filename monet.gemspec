# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monet/version'

Gem::Specification.new do |gem|
  gem.name          = "monet"
  gem.version       = Monet::VERSION
  gem.authors       = ["Luke van der Hoeven"]
  gem.email         = ["hungerandthirst@gmail.com"]
  gem.description   = %q{Monet is a web UI change comparer.}
  gem.summary       = %q{
    Monet captures your web pages, sets up a baseline
    and then ensures that future changes to either backend
    or front end code leaves your UI intact. No more wondering
    if CSS changes blow your UI up. Simply capture your page,
    make changes, run tests and compare the diff!
  }
  gem.homepage      = "plukevdh.github.com/monet"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('rake')
  gem.add_dependency('poltergeist')
  gem.add_dependency('capybara')
  # gem.add_dependency('chunky_png')
  gem.add_dependency('oily_png')
  gem.add_dependency('spidr')

  if RUBY_ENGINE == 'rbx'
    gem.add_dependency('rubysl')
    gem.add_dependency('racc')
    gem.add_dependency('json')
  end

  gem.add_development_dependency('rspec-given')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('timecop')
end
