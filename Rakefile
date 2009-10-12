require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.name        = "edamame"
    gem.authors     = ["Philip (flip) Kromer"]
    gem.email       = "flip@infochimps.org"
    gem.homepage    = "http://github.com/mrflip/edamame"
    gem.summary     = %Q{Beanstalk + Tokyo Tyrant = Edamame, a fast persistent distributed priority job queue.}
    gem.description = %Q{Edamame combines the Beanstalk priority queue with a Tokyo Tyrant database and God monitoring to produce a persistent distributed priority job queue system. \n\nLike beanstalk, it is fast, lightweight, distributed, priority queuing, reliable scheduling; it adds persistence, named jobs and job querying/enumeration. }
    gem.executables = FileList['bin/edamame-*'].pathmap('%f')
    gem.files       =  FileList["\w*", "{bin,docpages,examples,lib,spec,utils}/**/*"].reject{|file| file.to_s =~ %r{.*private.*} }
    gem.add_dependency 'tokyotyrant'
    gem.add_dependency 'wukong'
    gem.add_dependency 'monkeyshines'
    gem.add_dependency 'beanstalk-client'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end
Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end
task :spec => :check_dependencies
task :default => :spec

begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = ['lib/**/*.rb', 'examples/**/*.rb', 'utils/**/*.rb']
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |yard|
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  require 'rdoc'
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end
  rdoc.options += [
    '-SHN',
    '-f', 'darkfish',  # use darkfish rdoc styler
  ]
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "edamame #{version}"
  #
  File.open(File.dirname(__FILE__)+'/.document').each{|line| rdoc.rdoc_files.include(line.chomp) }
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features)
rescue LoadError
  task :features do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end
