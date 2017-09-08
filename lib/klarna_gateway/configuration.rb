module KlarnaGateway
  class << self
    attr_accessor :_configuration

    def configuration
      if self._configuration.nil?
        raise ConfigurationMissing.new("KlarnaGateway._configuration is missing. Please run <rails generate klarna_gateway:install> or create an initializer for this configuration")
      end
      self._configuration
    end

    def is_solidus?
      Spree.respond_to?(:solidus_version)
    end

    def is_spree?
      !is_solidus?
    end

    def up_to_solidus?(version)
      is_solidus? && Gem::Version.new(Spree.solidus_version) <= Gem::Version.new(version)
    end

    def up_to_spree?(version)
      is_spree? && Gem::Version.new(Spree.version) <= Gem::Version.new(version)
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
