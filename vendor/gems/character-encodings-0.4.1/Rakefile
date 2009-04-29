# contents: Rakefile for the unicode library.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'spec/rake/spectask'

PackageName = 'character-encodings'
PackageVersion = '0.4.1'

desc 'Default task'
task :default => [:extensions]

ExtensionDirectory = "ext/encoding/character"

extensions = [
  'utf-8'
].map{ |extension| File.join(ExtensionDirectory, extension) }

Make = 'make'
Makefile = 'Makefile'
ExtConf = 'extconf.rb'
Depend = 'depend'
TAGS = 'TAGS'
CTags = 'exuberant-ctags'

desc 'Build all C-based extensions'
task :extensions

extensions.each do |extension|
  makefile = File.join(extension, Makefile)
  so = File.join(extension, File.basename(extension).delete('-') + '.' + Config::CONFIG['DLEXT'])
  tags = File.join(extension, TAGS)

  task :extensions => [makefile, so, tags]

  begin
    sources = IO.read(makefile).grep(/^\s*SRCS/).first.sub(/^\s*SRCS\s*=\s*/, "").split(' ')
  rescue
    Dir.chdir(extension) do
      sources = FileList['*.c'].to_a
    end
  end

  file makefile => [ExtConf, Depend].map{ |tail| File.join(extension, tail) } do
    Dir.chdir(extension) do
      ruby ExtConf
      File.open(Makefile, 'a') do |f|
        f.puts <<EOF
TAGS:
	@echo Running ‘ctags’ on source files…
	@#{CTags} -f $@ -I UNUSED,HIDDEN,_ $(SRCS)

tags: TAGS

all: tags

.PHONY: tags
EOF
      end
    end
  end

  extension_sources = sources.map{ |source| File.join(extension, source) }

  file so => extension_sources do
    sh %{#{Make} -C #{extension}}
    # TODO: Perhaps copying the ‘so’ to “lib” could save us some trouble with
    # how libraries are loaded.
  end

  file tags => extension_sources do
    sh %{#{Make} -C #{extension} tags}
  end
end

desc 'Extract embedded documentation and build HTML documentation'
task :doc => [:rdoc]
task :rdoc => FileList['**/*.c', '**/*.rb']

desc 'Clean up by removing all generated files, e.g., documentation'
task :clean => [:clobber_rdoc]

Spec::Rake::SpecTask.new do |t|
  t.warning = true
  t.libs = ['lib', 'ext']
  t.spec_files = FileList['specifications/*.rb']
end

Tests = [
  ['tests/foldcase.rb', 'tests/case.rb'],
  ['tests/normalize.rb']
]

Rake::TestTask.new do |t|
  level = ENV['level'] ? Integer(ENV['level']) : 0
  t.test_files = Tests[0..level].flatten
  t.libs = ['lib', 'ext']
  t.verbose = true
end

RDocDir = 'api'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = RDocDir
  rdoc.title = 'Unicode'
  rdoc.options = ['--charset UTF-8']
  rdoc.rdoc_files.include('**/*.c')
  rdoc.rdoc_files.include('**/*.rb')
end

PackageFiles = %w(README Rakefile) +
  Dir.glob("{lib,specifications}/**/*") +
  Dir.glob("ext/**/{*.{c,h,rb},depend}") +
  Dir.glob("tests/*.rb")

spec =
  Gem::Specification.new do |s|
    s.name = PackageName
    s.version = PackageVersion
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = false
    s.extra_rdoc_files = []
    s.summary = 'A pluggable character-encoding library'
    s.description = s.summary
    s.author = 'Nikolai Weibull'
    s.email = 'now@bitwi.se'
    s.homepage = 'http://git.bitwi.se/?p=ruby-character-encodings.git;a=summary'
    s.files = PackageFiles
    s.require_path = "lib"
    s.extensions = FileList["ext/**/extconf.rb"].to_a
  end

PackagesDirectory = 'packages'

Rake::GemPackageTask.new(spec) do |p|
  p.package_dir = PackagesDirectory
  p.need_tar_gz = true
  p.gem_spec = spec
end

desc 'Install the gem for this project'
task :install => [:package] do
  sh %{gem install #{PackagesDirectory}/#{PackageName}-#{PackageVersion}}
end

desc 'Uninstall the gem for this package'
task :uninstall => [] do
  sh %{gem uninstall #{PackageName}}
end

CLEAN.include ["ext/**/{*.{o,so},#{TAGS}}"]
CLOBBER.include ["ext/**/#{Makefile}"]
