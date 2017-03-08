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

RSpec::Core::RakeTask.new



namespace :klarna_gateway do
  namespace :spec do
    desc 'Generates a dummy app for testing'
    task :create_dummy_app do
      ENV['LIB_NAME'] = 'klarna_gateway'
      Rake::Task['common:test_app'].invoke
    end

    desc "Prepares database for testing Alchemy"
    task :prepare do
      system 'cd spec/dummy && \
        RAILS_ENV=test bundle exec rake db:drop db:create && \
        RAILS_ENV=test bundle exec rake railties:install:migrations db:migrate&& \
        ADMIN_EMAIL=admin@example.com ADMIN_PASSWORD=test123 RAILS_ENV=test bundle exec rake db:seed spree_sample:load && \
        cd -'
    end
  end
end

task :default do
  if Dir["spec/dummy"].empty?
    Rake::Task['klarna_gateway:spec:create_dummy_app'].invoke
    Dir.chdir("../../")
  end

  Rake::Task['klarna_gateway:spec:prepare'].invoke
  Rake::Task['spec'].invoke
end
