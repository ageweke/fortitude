if defined?(ActiveSupport)
  ActiveSupport.on_load(:before_initialize) do
    ActiveSupport.on_load(:action_view) do
      require "fortitude/rails/template_handler"
    end
  end
end

module Fortitude
  class Railtie < ::Rails::Railtie
    initializer :fortitude do |app|
      require "fortitude/rails/template_handler"
    end
  end
end
