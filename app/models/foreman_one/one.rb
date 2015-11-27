module ForemanOne
  class One < ::ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy

    validates :user, :password, :presence => true
    validates :url, :format => { :with => URI.regexp }

    def self.provider_friendly_name
      "OpenNebula"
    end

    def provided_attributes
      super.merge({ :uuid => :identity_to_s, :mac => :mac })
    end

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build]
    end

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    end

    def new_vm attr={ }
      client.servers.new vm_instance_defaults.merge(attr.to_hash.symbolize_keys) if errors.empty?
    end

    def interfaces
      vm.interfaces
    end

    def vminterfaces
      interfaces
    end

    def networks
      client.networks rescue []
    end


    def flavors
      client.flavors
    end

    def groups
      client.groups
    end

    def create_vm args = { }
      args = vm_instance_defaults.merge(args.to_hash.symbolize_keys)
      logger.info "CREATEVM ARGS #{args.inspect}"
      #ARGS: {"name"=>"aaa.example.com", "b0e"=>"foob0e", "foob0e"=>"b0e", "template_id"=>"4", "vcpu"=>"", "memory"=>"", "vminterfaces_attributes"=>{"new_interfaces"=>{"vnetid"=>"0", "_delete"=>"", "model"=>"virtio"}, "new_1398239695352"=>{"vnetid"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239700415"=>{"vnetid"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239705632"=>{"vnetid"=>"0", "_delete"=>"", "model"=>"e1000"}}}

      vm = client.servers.new
      vm.name = args[:name]
      vm.gid = args[:gid] unless args[:gid].empty?
      vm.flavor = client.flavors.get(args[:template_id])

      vm.flavor.vcpu = args[:vcpu] unless args[:vcpu].empty?
      vm.flavor.memory = args[:memory] unless args[:memory].empty?
      vm.flavor.nic = [] unless vm.flavor.nic.is_a? Array

      #INTERFACES {"new_interfaces"=>{"vnetid"=>"0", "_delete"=>"", "model"=>"virtio"}, "new_1398239695352"=>{"vnetid"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239700415"=>{"vnetid"=>"2", "_delete"=>"", "model"=>"virtio"}, "new_1398239705632"=>{"vnetid"=>"0", "_delete"=>"", "model"=>"e1000"}}
      logger.debug "NEW #{args[:interfaces_attributes].inspect}"
      nics = args[:interfaces_attributes].values
      if nics.is_a? Array then
        nics.each do |nic|
          unless (nic["vnetid"].empty? || nic["model"].empty?)
            vm.flavor.nic << client.interfaces.new({ :vnet => client.networks.get(nic["vnetid"]), :model => nic["model"]})
          end
        end
      end

      logger.debug "VM: #{vm.inspect}"
      logger.debug "FLAVOR: #{vm.flavor.inspect}"
      logger.debug "NIC: #{vm.flavor.nic.inspect}"
      logger.debug "FLAVORto_s: #{vm.flavor.to_s}"

      vm.save
    rescue ::OpenNebula::Error => e
      logger.debug "OpenNebula error: #{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base, e.message.to_s)
      false
    end

    def test_connection options = {}
      super
      errors[:user].empty? and errors[:password].empty? and not client.client.get_version.is_a?(OpenNebula::Error)
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console_output.body.merge(:type=>'vnc', :name=>vm.name)
    end

    def destroy_vm(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.destroy if vm
      true
    end

    def start_vm(uuid)
      #vm = find_vm_by_uuid(uuid)
      #logger.info "VM DESTROY: #{vm.class} #{vm.methods}"
      #vm.destroy if vm
      true
    end

    # not supporting update at the moment
    def update_required?(old_attrs, new_attrs)
      false
    end

#    def associated_host(vm)
#      Host.my_hosts.where(:ip => [vm.public_ip_address, vm.private_ip_address]).first
#    end

    def associated_host(vm)
      #Host.my_hosts.where(:mac => [vm.vm_mac_address]).first
      Host.authorized(:view_hosts, Host).where(:mac => vm.vm_mac_address).first
    end

    def new_vminterface attr={}
      logger.info "new_interface attr #{attr.inspect}"
      client.interfaces.new attr
    end

    private

    def client
      @client ||= ::Fog::Compute.new({:provider => 'OpenNebula', :opennebula_username => user, :opennebula_password => password, :opennebula_endpoint => url})
    end

    def vm_instance_defaults
      super
    end
  end
end
