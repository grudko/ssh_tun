#
# Cookbook Name:: ssh_tun
# Resource:: ssh_tunnel

actions :add, :remove, :restart

attribute :remote_host, :kind_of => String, :name_attribute => true
attribute :remote_port, :kind_of => String
attribute :local_port, :kind_of => String
attribute :gateway, :kind_of => String, :default => "192.168.0.1"
attribute :key_file, :kind_of => String, :default => "/root/.ssh/id_rsa"
attribute :gw_key_file, :kind_of => String, :default => "/root/.ssh/id_rsa"
attribute :remote_user, :kind_of => String, :default => "root"
attribute :gateway_user, :kind_of => String, :default => "root"
