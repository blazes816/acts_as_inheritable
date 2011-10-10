# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "acts_as_inheritable/version"

Gem::Specification.new do |s|
  s.name        = "acts_as_inheritable"
  s.version     = ActsAsInheritable::VERSION
  s.authors     = ["Tyler Smith"]
  s.email       = ["blazes816@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Allows ActiveRecord models to be inherited}
  s.description = %q{Allows ActiveRecord models to be inherited}

  s.rubyforge_project = "acts_as_inheritable"

  s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "active-record"
  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
