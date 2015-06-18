# -*- encoding: utf-8 -*-

require File.expand_path('../lib/motion-async/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = "motion-async"
  spec.summary = "A Ruby wrapper around Android's AsyncTask"
  spec.description = "MotionAsync was written for use with RubyMotion Android, and makes it easy to run code off the main UI thread by providing a friendly wrapper around Android's AsyncTask class."
  spec.authors = ["Darin Wilson"]
  spec.email = "darinwilson@gmail.com"
  spec.homepage = "http://github.com/darinwilson/motion-async"
  spec.version = MotionAsync::VERSION
  spec.license = "MIT"

  files = []
  files << "README.md"
  files << "LICENSE"
  files.concat(Dir.glob("lib/**/*.rb"))
  spec.files = files
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bacon"
  spec.add_development_dependency "rake"
end
