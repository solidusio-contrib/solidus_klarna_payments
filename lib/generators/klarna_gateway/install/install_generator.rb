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
  # config.confirmation_url = ->(order) { url_helpers.order_url(order.number, host: "my host") }
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
