module KlarnaGateway
  module Generators
    class InstallGenerator < Rails::Generators::Base

      class_option :auto_run_migrations, :type => :boolean, :default => false

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=klarna_gateway'
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/klarna_gateway\n", before: /\*\//, verbose: true
      end

      def add_initializer
        initializer "klarna_gateway.rb" do
          <<-INIT
KlarnaGateway.configure do |config|
  ## Generate the completion route dynamically
  # expected:
  # config.confirmation_url = <String>
  # config.confirmation_url = <Proc>
  # Examples:
  # config.confirmation_url = helpers.path_to_order
  # config.confirmation_url = ->(store, order) { url_helpers.order_url(order.number, host: store.url) }
  #
  # When this value is set to true you can cancel all Solidus/Spree orders without checking the Klarna payment status.
  # When this value is set to false only orders which klarna's payments are in authorized status can be cancelled (No autocaptured orders)
  # config.cancel_order_without_klarna_verification = (true|false)
end
          INIT
        end
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
