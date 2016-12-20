module KlarnaGateway
  class << self
    attr_accessor :_configuration

    def configuration
      if self._configuration.nil?
        raise ConfigurationMissing.new("KlarnaGateway._configuration is missing. Please run <rails generate klarna_gateway:install> or create an initializer for this configuration")
      end
      self._configuration
    end
  end

  def self.configure
    self._configuration ||= Configuration.new
    yield(self._configuration)
  end

  class Configuration
    attr_accessor :confirmation_url
  end

  class ConfigurationMissing < StandardError; end
end
