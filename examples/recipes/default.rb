#
# Cookbook Name:: ssh_tun
# Recipe:: default
#
# Copyright 2011, Anton Grudko
#
# All rights reserved - Do Not Redistribute
#

#SSH tunnel thru default gateway
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

#SSH tunnel thru custom gateway
ssh_tun_tunnel "28081" do
  local_port "28081"
  remote_host "192.168.0.60"
  remote_port "25"
  remote_user "anton"
  gateway_user "grudko"
  gateway "10.10.10.1"
  key_file "/home/anton/.ssh/id_rsa"
  gw_key_file "/home/anton/.ssh/id_rsa"
  action :add
end

#Restart all node tunnels by run restart_all definition
restart_all do
end
