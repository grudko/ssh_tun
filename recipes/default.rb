#
# Cookbook Name:: ssh_tun
# Recipe:: default
#
# Copyright 2011, Anton Grudko
#
# All rights reserved - Do Not Redistribute
#

package "autossh" do
 action :upgrade
end

directory "/var/run/ssh_tun" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

ssh_tun_tunnel "28080" do
  local_port "28080"
  remote_host "192.168.0.60"
  remote_port "80"
  remote_user "anton"
  gateway_user "grudko"
  key_file "/home/anton/.ssh/id_rsa"
  gw_key_file "/home/anton/.ssh/id_rsa"
  action :add
end

ssh_tun_tunnel "28081" do
  local_port "28081"
  remote_host "192.168.0.60"
  remote_port "25"
  remote_user "anton"
  gateway_user "grudko"
  key_file "/home/anton/.ssh/id_rsa"
  gw_key_file "/home/anton/.ssh/id_rsa"
  action :add
end

ruby_block "restart_all" do
 block do
  node[:ssh_tun].each do |tun|
    Chef::Log.info "Tunnel: #{tun}"
    notifies :restart, resources( :ssh_tun_tunnel => [ "#{tun}" ] )
  end
 end
end
