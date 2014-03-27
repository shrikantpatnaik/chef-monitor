#
# Cookbook Name:: monitor
# Recipe:: _mailer_handler
#
# Copyright 2013, Shrikant Patnaik 
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

sensu_gem "mail"

cookbook_file "/etc/sensu/handlers/mailer.rb" do
  source "handlers/mailer.rb"
  mode 0755
end

sensu_handler "mailer" do
  type "pipe"
  command "mailer.rb"
end

template "/etc/sensu/conf.d/mailer.json" do
  source "mailer.json.erb"
  mode 0640
  group "sensu"
  variables({
      mailer: node[:monitor][:mailer]
  })
end

include_recipe "sensu::server_service"
