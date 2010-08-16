# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{edamame}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Philip (flip) Kromer"]
  s.date = %q{2010-08-16}
  s.description = %q{Edamame combines the Beanstalk priority queue with a Tokyo Tyrant database and God monitoring to produce a persistent distributed priority job queue system. 

Like beanstalk, it is fast, lightweight, distributed, priority queuing, reliable scheduling; it adds persistence, named jobs and job querying/enumeration. }
  s.email = %q{flip@infochimps.org}
  s.executables = ["edamame-nuke", "edamame-sync", "edamame-stats"]
  s.extra_rdoc_files = [
    "LICENSE.textile",
     "README.textile"
  ]
  s.files = [
    "LICENSE.textile",
     "README.textile",
     "app/edamame_san/config.ru",
     "app/edamame_san/config.yml",
     "app/edamame_san/edamame_san.rb",
     "app/edamame_san/public/favicon.ico",
     "app/edamame_san/public/images/edamame_logo.icns",
     "app/edamame_san/public/images/edamame_logo.ico",
     "app/edamame_san/public/images/edamame_logo.png",
     "app/edamame_san/public/images/edamame_logo_2.icns",
     "app/edamame_san/public/javascripts/application.js",
     "app/edamame_san/public/javascripts/jquery/jquery-ui.js",
     "app/edamame_san/public/javascripts/jquery/jquery.js",
     "app/edamame_san/public/stylesheets/application.css",
     "app/edamame_san/public/stylesheets/layout.css",
     "app/edamame_san/views/layout.haml",
     "app/edamame_san/views/load.haml",
     "app/edamame_san/views/root.haml",
     "bin/edamame-nuke",
     "bin/edamame-ps",
     "bin/edamame-stats",
     "bin/edamame-sync",
     "bin/edamame_util_opts.rb",
     "bin/test_run.rb",
     "lib/edamame.rb",
     "lib/edamame/broker.rb",
     "lib/edamame/job.rb",
     "lib/edamame/monitoring.rb",
     "lib/edamame/persistent_queue.rb",
     "lib/edamame/queue.rb",
     "lib/edamame/queue/beanstalk.rb",
     "lib/edamame/scheduling.rb",
     "lib/edamame/store.rb",
     "lib/edamame/store/base.rb",
     "lib/edamame/store/tyrant_store.rb",
     "lib/methods.txt",
     "spec/edamame_spec.rb",
     "spec/spec_helper.rb",
     "utils/god/edamame.god",
     "utils/god/edamame.yaml",
     "utils/god/god-etc-init-dot-d-example",
     "utils/god/god.conf",
     "utils/god/god_site_config.rb",
     "utils/god/wuclan.god",
     "utils/simulation/Add Percent Variation.vi",
     "utils/simulation/Harmonic Average.vi",
     "utils/simulation/Rescheduling Simulation.aliases",
     "utils/simulation/Rescheduling Simulation.lvlps",
     "utils/simulation/Rescheduling Simulation.lvproj",
     "utils/simulation/Rescheduling.vi",
     "utils/simulation/Weighted Average.vi"
  ]
  s.homepage = %q{http://github.com/mrflip/edamame}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Beanstalk + Tokyo Tyrant = Edamame, a fast persistent distributed priority job queue.}
  s.test_files = [
    "spec/spec_helper.rb",
     "spec/edamame_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<beanstalk-client>, [">= 0"])
      s.add_runtime_dependency(%q<wukong>, [">= 0"])
      s.add_runtime_dependency(%q<monkeyshines>, [">= 0"])
    else
      s.add_dependency(%q<beanstalk-client>, [">= 0"])
      s.add_dependency(%q<wukong>, [">= 0"])
      s.add_dependency(%q<monkeyshines>, [">= 0"])
    end
  else
    s.add_dependency(%q<beanstalk-client>, [">= 0"])
    s.add_dependency(%q<wukong>, [">= 0"])
    s.add_dependency(%q<monkeyshines>, [">= 0"])
  end
end

