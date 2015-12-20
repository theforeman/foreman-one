require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog/opennebula'

module ForemanOne
  # Inherit from the Rails module of the parent app (Foreman), not the plugin.
  # Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    initializer 'foreman_one.register_gettext', :after => :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'one'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_one.register_plugin', :after => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_one do
        requires_foreman '>= 1.8'
        # Register OpenNebula compute resource in foreman
        compute_resource ForemanOne::One
      end
    end

    config.to_prepare do
      begin
        # extend fog opennebula server/
        require 'fog/opennebula/models/compute/server'
        require File.expand_path('../../../app/models/concerns/fog_extensions/opennebula/server', __FILE__)

        Fog::Compute::OpenNebula::Server.send(:include, ::FogExtensions::OpenNebula::Server)
        ::HostsHelper.send(:include, ForemanOne::HostHelperExtensions)
      rescue => e
        Rails.logger.warn "Foreman-One: skipping engine hook (#{e})"
      end
    end
  end
end
