#
# Cookbook Name:: ssh_tun
# Provider:: tunnel
#

action :add do
 Chef::Log.info "Dependencies resolution"
 package "autossh" do
  action :upgrade
 end
 directory "/var/run/ssh_tun" do
  owner "root"
  group "root"
  mode "0755"
  action :create
 end
 Chef::Log.info "Adding ssh tunnel"
 add_tun
 ruby_block "add_host_attribute" do
  block do
   node.set['ssh_tun']["#{new_resource.name}"]
   node.save
  end
 end
end

action :remove do
 Chef::Log.info "Removing ssh tunnel"
 remove_tun
 ruby_block "del_host_attribute" do
  block do
   node.delete['ssh_tun']["#{new_resource.name}"]
   node.save
  end
 end
end

action :restart do
 Chef::Log.info "Restarting ssh tunnel"
 remove_tun
 add_tun
end

private

def add_tun
 unless ::File.exists?("/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-to-#{new_resource.gateway}.pid")
  bash "create tunnel" do
   code <<-EOH
    Port=61000

    while netstat -atwn | grep "^.*:${Port}.*:\*\s*LISTEN\s*$"
    do
     Port=$(( ${Port} - 1 ))
    done
    export Port
    (AUTOSSH_PIDFILE=/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-to-#{new_resource.gateway}.pid AUTOSSH_POLL=30 \
    autossh -n -N  -o StrictHostKeyChecking=no -l #{new_resource.gateway_user} -i #{new_resource.gw_key_file} -L $Port:#{new_resource.remote_host}:22 #{new_resource.gateway} &) &
    sleep 1
    (AUTOSSH_PIDFILE=/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-thru-#{new_resource.gateway}.pid AUTOSSH_POLL=30 \
    autossh -n -N -p $Port -o StrictHostKeyChecking=no -l #{new_resource.remote_user} -i #{new_resource.key_file} -L #{new_resource.local_port}:#{new_resource.remote_host}:#{new_resource.remote_port} localhost &) &
   EOH
   action :nothing
  end.run_action(:run)
  new_resource.updated_by_last_action(true)
 end
end

def remove_tun
 if ::File.exists?("/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-thru-#{new_resource.gateway}.pid")
  bash "remove tunnel to host" do
  code <<-EOH
   kill `cat /var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-thru-#{new_resource.gateway}.pid`
  EOH
   action :nothing
  end.run_action(:run)
  file "/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-thru-#{new_resource.gateway}.pid" do
   action :delete
  end
  new_resource.updated_by_last_action(true)
 end
 if ::File.exists?("/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-to-#{new_resource.gateway}.pid") 
  bash "remove tunnel to gateway" do
   code <<-EOH
    kill `cat /var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-to-#{new_resource.gateway}.pid`
   EOH
   action :nothing
  end.run_action(:run)
  file "/var/run/ssh_tun/#{new_resource.remote_host}-#{new_resource.remote_port}-thru-#{new_resource.gateway}.pid" do
   action :delete
  end
  new_resource.updated_by_last_action(true)
 end
end
