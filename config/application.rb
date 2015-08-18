require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'active_record/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

Bundler.require(:default, :assets, Rails.env)

module Gubernator
  class Application < Rails::Application
    config.assets.precompile += %w( *.png *.jpg *.jpeg *.gif  )

    config.autoload_paths += %W(
      #{config.root}/lib
    )

    config.time_zone = 'Novosibirsk'
    config.i18n.default_locale = :ru
    config.i18n.available_locales = [:ru, :en]
    config.middleware.insert_before 'Rack::Runtime', Rack::UTF8Sanitizer
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.assets.paths << Rails.root.join('app', 'assets', 'uppod')
  end
end
