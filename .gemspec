# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/bahia"

Gem::Specification.new do |s|
  s.name        = "bahia"
  s.version     = Bahia::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://github.com/cldwalker/bahia"
  s.summary =  "aruba for non-cucumber test frameworks"
  s.description = "Bahia - where commandline acceptance tests are easy, the people are festive and onde nasceu capoeira. In other words, aruba for any non-cucumber test framework."
  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency 'systemu', '~> 2.4.2'
  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.files = Dir.glob(%w[{lib,spec}/**/*.rb bin/* [A-Z]*.{md,txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.files += %w{.travis.yml}
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = 'MIT'
end
