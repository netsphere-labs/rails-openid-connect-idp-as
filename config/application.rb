require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenidConnectOpSample
  class Application < Rails::Application
    # Default: 自動的にすべての helpers が `include` される.
    # 次の設定でコントローラと同名のヘルパに限定できる
    config.action_controller.include_all_helpers = false

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # The UserInfo Endpoint MUST accept Access Tokens as OAuth 2.0 Bearer Token
    # Usage [RFC6750].
    config.middleware.use Rack::OAuth2::Server::Resource::Bearer, 'OpenID Connect' do |req|
      AccessToken.where('token = ? AND expires_at >= ?',
                        req.access_token, Time.now.utc).take || req.invalid_token!
    end

  end
end
