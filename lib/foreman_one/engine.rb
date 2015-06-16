require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog/opennebula'

module ForemanOne
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    initializer 'foreman_one.register_gettext', :after => :load_config_initializers do |app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'one'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_one.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_one do
        requires_foreman '> 1.4'
        # Register OpenNebula compute resource in foreman
        compute_resource ForemanOne::One
      end
    end

  end
end
