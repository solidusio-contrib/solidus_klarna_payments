module PageDrivers
  class Base
    include Capybara::DSL

    def initialize(page)
      @page = page
    end

    def method_missing(m, *args, &block)
      if @page.respond_to?(m)
        @page.send(m, *args)
      end
    end
  end
end

