# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require "motion/project/template/android"
require "./lib/motion-async"

begin
  require "bundler"
  require "motion/project/template/gem/gem_tasks"
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = "MotionAsync"
  app.archs = ["x86"] unless ARGV.include?("device") || ARGV.include?("archive")
  app.main_activity = "MainActivity"
end
