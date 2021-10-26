# frozen_string_literal: true

module SolidusKlarnaPayments
  class BaseService
    def self.call(*args, **kws, &block)
      new(*args, **kws, &block).call
    end

    def call
      raise NotImplementedError
    end
  end
end
