require "dotenv"
Dotenv.load

require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require "awesome_print"
require "rspec/core/rake_task"
require 'spree/testing_support/common_rake'

dummy_rake_file = File.expand_path("../spec/dummy/Rakefile", __FILE__)

if File.exist?(dummy_rake_file)
  APP_RAKEFILE = dummy_rake_file
  load 'rails/tasks/engine.rake'
  Rails.application.load_tasks
end

module KlarnaOutputHelper

  def self.pe(command)
    ap "Executing: " << command
    command = "cd spec/dummy && RAILS_ENV=test " << command  << " > /dev/null 2>&1"
    system command
  end

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
      KlarnaOutputHelper.pe "bundle exec rake db:drop db:create"
      KlarnaOutputHelper.pe "bundle exec rake railties:install:migrations"
      KlarnaOutputHelper.pe "bundle exec rake db:migrate"
      KlarnaOutputHelper.pe "ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD=test123 bundle exec rake db:seed"
      KlarnaOutputHelper.pe "bundle exec rake spree_sample:load"
    end

    desc "Run BDD tests"
    task :run do
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
      KlarnaOutputHelper.pe "bundle exec rake db:drop db:create db:schema:load"
    end

    desc "Run TDD tests"
    task :run do
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
