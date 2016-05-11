module SpreePingppHtml5
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_pingpp'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "javascripts", "spree")
      Rails.application.config.assets.precompile += %w{ pingpp.js frontend/spree_pingpp }
    end

    config.after_initialize do |app|
      app.config.spree.payment_methods += [
        Spree::Gateway::PingppPc,
        Spree::Gateway::PingppWeixin
      ]
    end
  end
end
