require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'

def __DIR__
  File.dirname(__FILE__)
end
include FileUtils

NAME = "packet"
$LOAD_PATH.unshift __DIR__+'/lib'
require 'packet'

CLEAN.include ['**/.*.sw?', '*.gem', '.config','*.rbc']
Dir["tasks/**/*.rake"].each { |rake| load rake }


@windows = (PLATFORM =~ /win32/)

SUDO = @windows ? "" : (ENV["SUDO_COMMAND"] || "sudo")



desc "Packages up Packet."
task :default => [:package]

task :doc => [:rdoc]

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = Packet::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README", "MIT-LICENSE", 'TODO']
  #s.rdoc_options += RDOC_OPTS +
  #  ['--exclude', '^(app|uploads)']
  s.summary = "Packet, A Pure Ruby library for Event Driven Network Programming."
  s.description = s.summary
  s.author = "Hemant Kumar"
  s.email = 'mail@gnufied.org'
  s.homepage = 'http://code.google.com/p/packet/'
  s.required_ruby_version = '>= 1.8.5'
  s.files = %w(MIT-LICENSE README Rakefile TODO) + Dir.glob("{spec,lib,examples}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.executables = "packet_worker_runner"
end

Rake::GemPackageTask.new(spec) do |p|
  #p.need_tar = true
  p.gem_spec = spec
end

task :install do
  sh %{rake package}
  sh %{#{SUDO} gem install pkg/#{NAME}-#{Packet::VERSION} --no-rdoc --no-ri}
end

task :uninstall => [:clean] do
  sh %{#{SUDO} gem uninstall #{NAME}}
end

desc "Converts a YAML file into a test/spec skeleton"
task :yaml_to_spec do
  require 'yaml'

  puts YAML.load_file(ENV['FILE']||!puts("Pass in FILE argument.")&&exit).inject(''){|t,(c,s)|
    t+(s ?%.context "#{c}" do.+s.map{|d|%.\n  xspecify "#{d}" do\n  end\n.}*''+"end\n\n":'')
  }.strip
end

