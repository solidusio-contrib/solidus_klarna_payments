module WorkflowDriver
  module Process
    def method_missing(m, *args, &block)
      if (matches = /on_the_(?<page>.*?)_page/.match(m))
        class_name = matches[:page]
        if (admin = /^admin/.match(matches[:page]))
          class_name = class_name.gsub("admin_", "admin/")
        end

        unless instance_variable_get("@#{matches[:page]}")
          instance_variable_set("@#{matches[:page]}", "page_drivers/#{class_name}".camelize.constantize.new)
        end

        if block_given?
          return yield instance_variable_get("@#{matches[:page]}")
        end
        instance_variable_get("@#{matches[:page]}")
      end
    end

  end
end
