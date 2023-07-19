# frozen_string_literal: true

module SolidusKlarnaPayments
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option :auto_run_migrations, type: :boolean, default: false
      source_root File.expand_path('templates', __dir__)

      def self.exit_on_failure?
        true
      end

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_klarna_payments.rb'
      end

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/frontend/all.js',
          "//= require spree/frontend/solidus_klarna_payments\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_klarna_payments\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_klarna_payments\n", before: %r{\*/}, verbose: true # rubocop:disable Layout/LineLength
      end

      def mount_engine
        insert_into_file File.join('config', 'routes.rb'), after: "mount Spree::Core::Engine, at: '/'\n" do
          "  mount SolidusKlarnaPayments::Engine, at: '/solidus_klarna_payments'\n"
        end
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_klarna_payments'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]')) # rubocop:disable Layout/LineLength
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
