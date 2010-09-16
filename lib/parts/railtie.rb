require "parts"
require 'rails'

module Parts
  class Railtie < Rails::Railtie
    initializer "parts.include_helpers" do |app|
      ActiveSupport.on_load(:action_controller) do
        ActionView::Base.send(:include, Parts::Helpers)
        ActionController::Base.send(:include, Parts::Helpers)
        ActionController::Base.helper_method(:part)
      end
    end

    initializer "parts.set_paths" do |app|
      paths = app.config.paths

      Dir.glob(File.join(app.root.to_s, 'app', 'parts', '*')).each do |path|
        Rails::Paths::Path.new(paths, [path, {:eager_load => true}])
        #paths.app.parts path, :eager_load => true ## OLD
      end

      Dir.glob(File.join(app.root.to_s, 'app', 'parts', '*', 'views')).each do |path|
        #paths.app.parts.views path ## OLD
        Rails::Paths::Path.new(paths, path)
        Parts::Base.append_view_path path
      end

      #paths.app.parts.views.to_a.each do |path|
        #Parts::Base.append_view_path path ## OLD
      #end

      Parts::Base.helpers_path = paths.app.helpers.to_a.first
    end
  end
end
