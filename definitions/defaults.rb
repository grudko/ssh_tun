define :restart_all do
 Chef::Log.info "Restarting all node tunnels"
 ruby_block "restart_all" do
  block do
   node[:ssh_tun].each do |tun|
     Chef::Log.info "Restarting tunnel: #{tun}"
     notifies :restart, resources( :ssh_tun_tunnel => [ "#{tun}" ] )
   end
  end
 end
end
