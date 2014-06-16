require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "fileutils"

RSpec::Core::RakeTask.new(:spec)

default_prerequisites = [ :spec ]
if defined?(RUBY_ENGINE) && RUBY_ENGINE.to_s.strip.downcase == 'jruby'
  default_prerequisites = [ 'jruby:clean', 'jruby:compile' ] + default_prerequisites
else
  default_prerequisites = [ :clobber, :compile ] + default_prerequisites
end

task :default => default_prerequisites

require 'rake/extensiontask'
spec = Gem::Specification.load('fortitude.gemspec')
Rake::ExtensionTask.new('fortitude_native_ext', spec)

namespace :jruby do
  base_directory = File.expand_path(File.dirname(__FILE__))
  jar_path = File.join(base_directory, 'lib', 'fortitude_jruby_native_ext.jar')
  source_path = File.join(base_directory, 'ext')
  classes_output_path = File.join(base_directory, 'tmp', 'classes')
  jruby_jar_path = File.join(RbConfig::CONFIG['libdir'], 'jruby.jar')

  def safe_system(cmd)
    output = `#{cmd} 2>&1`
    unless $?.success?
      raise "Command failed:\n  #{cmd}\nreturned #{$?.inspect}, and produced output:\n#{output}"
    end
  end

  task :ensure_jruby do
    unless RUBY_ENGINE == 'jruby'
      raise "You must run this task using JRuby, not #{RUBY_ENGINE}"
    end
  end

  desc "Cleans all temporary files and the JAR from the JRuby extension"
  task :clean => [ :ensure_jruby ] do
    to_remove = [ classes_output_path, jar_path ]
    to_remove.each { |r| FileUtils.rm_rf(r) }
    puts "Cleaned: #{to_remove.join(", ")}"
  end

  desc "Compiles the JRuby extension"
  task :compile => [ :ensure_jruby ] do
    require 'find'

    files = [ ]
    Find.find(source_path) do |f|
      files << "'#{f}'" if f =~ /\.java$/i
    end

    FileUtils.mkdir_p(classes_output_path)
    FileUtils.mkdir_p(File.dirname(jruby_jar_path))

    puts "Compiling #{files.length} Java source files."
    safe_system("javac -cp '#{jruby_jar_path}' -g -sourcepath '#{source_path}' -d '#{classes_output_path}' #{files.join(" ")}")
    FileUtils.rm_rf(jar_path)
    puts "Building JAR."
    Dir.chdir(classes_output_path) do
      safe_system("jar cf '#{jar_path}' .")
    end
  end
end
