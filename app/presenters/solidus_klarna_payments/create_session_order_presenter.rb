# frozen_string_literal: true

module SolidusKlarnaPayments
  class CreateSessionOrderPresenter
    def initialize(order:, klarna_payment_method:, store:, skip_personal_data:)
      @order = order
      @klarna_payment_method = klarna_payment_method
      @store = store
      @skip_personal_data = skip_personal_data
    end

    def serialized_order
      return @serialized_order if defined? @serialized_order

      @serialized_order = order.to_klarna(klarna_payment_method.options[:country])
      @serialized_order.intent = 'TOKENIZE' if klarna_payment_method.preferred_tokenization
      @serialized_order.options = options
      @serialized_order.skip_personal_data = skip_personal_data
      @serialized_order.design = klarna_payment_method.options[:design]
      @serialized_order.store = store
      @serialized_order
    end

    delegate :to_hash, to: :serialized_order

    private

    def options
      klarna_payment_method.options.select do |key, value|
        key.to_s.start_with?('color_', 'radius_') && value.present?
      end
    end

    attr_reader :order, :klarna_payment_method, :store, :skip_personal_data
  end
end
