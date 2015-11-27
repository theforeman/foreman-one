module FogExtensions
  module OpenNebula
    module Server
      extend ActiveSupport::Concern

      def vminterfaces
        interfaces
      end

      def select_nic(fog_nics, nic)
        fog_nics.detect {|fn| fn.vnet == nic.compute_attributes['vnetid']} # grab any nic on the same network
      end

      def vminterfaces_attributes=(attributes)
        true
      end

      def template_id
        ""
      end

      def identity_to_s
        identity.to_s
      end
    end
  end
end
