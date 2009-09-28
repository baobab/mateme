$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

begin

desc "Run all features"
task :features => 'db:test:prepare'
task :features => "features:all"
require 'cucumber/rake/task' 

namespace :features do
  Cucumber::Rake::Task.new(:all) do |t|
    t.fork = true
    t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
  end
  
  task :coverage => "test:coverage:clean"
  Cucumber::Rake::Task.new(:coverage) do |t|    
    t.rcov = true
    t.rcov_opts = %w{--rails --aggregate coverage/data --exclude osx\/objc,gems\/,spec\/,features\/,Rakefile}
    t.rcov_opts << %[-o "coverage/features"]    
  end
end

rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end
