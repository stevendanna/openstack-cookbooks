#
# Cookbook Name:: nova
# Recipe:: network
#
# Copyright 2010-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "nova::config"

#not using the nova_package to ensure the dnsmasq kills properly
package "nova-network" do
  options "--force-yes"
  action :install
end

service "nova-network" do
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart nova-network"
    stop_command "stop nova-network"
    start_command "start nova-network"
    status_command "status nova-network | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
  end
  supports :status => true, :restart => true
  action [:enable, :start]
end

#intercepts restarts for nova-network
execute "killall dnsmasq" do
  returns [0,1]
  subscribes :run, resources(:template => "/etc/nova/nova.conf")
  notifies :restart, resources(:service => "nova-network"), :immediately
end
