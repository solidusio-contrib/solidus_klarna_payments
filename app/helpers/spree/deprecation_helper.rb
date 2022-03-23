# frozen_string_literal: true

module Spree
  module DeprecationHelper
    def deprecation_warning
      Spree::Deprecation.warn(
        "\n----------------------------------------------------------------------\n" \
        "#{self.class} has been deprecated and might be removed in future versions.\n" \
        "Use #{self.class.to_s.gsub('::', '::Api::')} instead.\n" \
        "----------------------------------------------------------------------\n"
      )
    end
  end
end
