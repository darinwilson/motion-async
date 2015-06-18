unless defined?(Motion::Project::App)
  raise "This must be required from within a RubyMotion Rakefile"
end

lib_dir_path = File.dirname(File.expand_path(__FILE__))
Motion::Project::App.setup do |app|
  app.files.unshift(Dir.glob(File.join(lib_dir_path, "motion-async/**/*.rb")))
end
