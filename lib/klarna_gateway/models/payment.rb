module KlarnaGateway
  module Payment

    def self.included(base)
      delegate :can_refresh?, :can_extend_period?, :can_capture?, :can_cancel?, :can_release?, to: :source
    end

    def klarna_order
      provider.get(klarna_order_id).body
    end

    def refresh!
      provider.get_and_update_source(klarna_order_id)
    end

    def approve!
      provider.acknowledge(klarna_order_id).tap do |response|
        log_entries.create!(details: response.to_yaml)
      end
    end

    def extend_period!
      provider.extend_period(klarna_order_id).tap do |response|
        log_entries.create!(details: response.to_yaml)
      end
    end

    def release!
      provider.release(klarna_order_id).tap do |response|
        log_entries.create!(details: response.to_yaml)
      end
    end

    def cancel!
      provider.cancel(klarna_order_id).tap do |response|
        log_entries.create!(details: response.to_yaml)
      end
      void!
    end

    def is_klarna?
      source.present? && source.brand == :klarna_credit
    end

    private

    def klarna_order_id
      source.order_id
    end

    def provider
      payment_method.provider
    end
  end
end
