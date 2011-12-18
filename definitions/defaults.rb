define :restart_all do
 ruby_block "restart_all" do
  block do
   node[:ssh_tun].each do |tun|
     Chef::Log.info "Tunnel: #{tun}"
     notifies :restart, resources( :ssh_tun_tunnel => [ "#{tun}" ] )
   end
  end
 end
end

