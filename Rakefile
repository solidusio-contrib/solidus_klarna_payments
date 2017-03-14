require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
require 'spree/testing_support/common_rake'

dummy_rake_file = File.expand_path("../spec/dummy/Rakefile", __FILE__)

if File.exist?(dummy_rake_file)
  APP_RAKEFILE = dummy_rake_file
  load 'rails/tasks/engine.rake'
  Rails.application.load_tasks
end

namespace :klarna_gateway do
  namespace :spec do
    desc 'Generates a dummy app for testing'
    task :create_dummy_app do
      ENV['LIB_NAME'] = 'klarna_gateway'
      Rake::Task['common:test_app'].invoke
    end
  end

  namespace :bdd do
    desc "Prepares database for BDD tests"
    task :prepare do
      if Dir["spec/dummy"].empty?
        Rake::Task['klarna_gateway:spec:create_dummy_app'].invoke
        Dir.chdir("../../")
      end

      system 'cd spec/dummy && \
        RAILS_ENV=test bundle exec rake db:drop db:create && \
        RAILS_ENV=test bundle exec rake railties:install:migrations &> /dev/null && \
        RAILS_ENV=test bundle exec rake db:migrate &> /dev/null && \
        ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD=test123 RAILS_ENV=test bundle exec rake db:seed spree_sample:load && \
        cd -'
    end

    desc "Run BDD tests"
    task :run do
      Rake::Task['klarna_gateway:bdd:prepare'].invoke

      Rake::Task["spec"].clear
      begin
        RSpec::Core::RakeTask.new(:spec) do |t|
          t.rspec_opts = "--tag bdd"
        end
      rescue LoadError
        # no rspec available
      end

      Rake::Task["spec"].invoke
    end
  end

  namespace :tdd do
    desc "Prepare db for TDD tests"
    task :prepare do
      if Dir["spec/dummy"].empty?
        Rake::Task['klarna_gateway:spec:create_dummy_app'].invoke
        Dir.chdir("../../")
      end

      system 'cd spec/dummy && \
        RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load &> /dev/null && \
        cd -'
    end

    desc "Run TDD tests"
    task :run do
      Rake::Task['klarna_gateway:tdd:prepare'].invoke

      Rake::Task["spec"].clear
      begin
        RSpec::Core::RakeTask.new(:spec) do |t|
          t.rspec_opts = "--tag ~bdd"
        end
      rescue LoadError
        # no rspec available
      end

      Rake::Task["spec"].invoke
    end
  end
end


task :default, 'klarna_gateway:tdd:run'
