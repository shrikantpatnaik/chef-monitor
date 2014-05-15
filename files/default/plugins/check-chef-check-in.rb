#!/usr/bin/env ruby
#
# Check Chef Check In
# ===
#
# Queries chef server for last checked in time for all nodes
# Returns warning for all nodes which havent checked in in times greater than the -w option
# Returns error for all nodes which havent checked in in times greater than the -e option
#
# Original file taken from http://nclouds.com/alerting-for-stale-nodes-on-chef-with-nagios/
# Edited By Shrikant Patnaik <shrikant.patnaik@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'chef/config'
require 'chef/rest'
require 'chef/search/query'

class CheckChefCheckIn < Sensu::Plugin::Check::CLI

  OK_STATE = 0
  WARNING_STATE = 1
  CRITICAL_STATE = 2
  UNKNOWN_STATE = 3

  option :warn,
         :short => '-w WARN',
         :proc => proc {|a| a.to_i },
         :default => 1

  option :crit,
         :short => '-c CRIT',
         :proc => proc {|a| a.to_i },
         :default => 12

  option :node_name,
         :short => '-n NODE_NAME',
         :default => 'localhost'

  option :chef_server_url,
         :short => '-u CHEF_SERVER_URL',
         :default => 'https://localhost:443'

  option :client_key,
         :short => '-k CLIENT_KEY',
         :default => '/etc/chef/client.rb'

  option :exclude,
         :short => '-e EXCLUDE',
         :default => ''



  def run
    Chef::Config[:chef_server_url] = config[:chef_server_url]
    Chef::Config[:node_name] = config[:node_name]
    Chef::Config[:client_key] = config[:client_key]
    excluded_nodes = config[:excluded_nodes].split(",")
        critical = config[:crit]
    warning = config[:warn]

    if warning > critical || warning < 0
      puts "Warning: warning should be less than critical and bigger than zero"
      exit(WARNING_STATE)
    end

    query = Chef::Search::Query.new
    all_nodes = []
    cnodes = []
    wnodes = []

    query.search('node', "*:*") do |node|
      unless excluded_nodes.include?
        all_nodes << node
      end
    end

    all_nodes.each do |node|
      hours=(Time.now.to_i - node['ohai_time'].to_i)/3600
      if hours >= critical
        cnodes << node.name
      elsif hours >= warning
        wnodes << node.name
      end
    end

    if cnodes.length > 0
      puts "CRITICAL: "+cnodes.join(',')+" did not check in for "+critical.to_s+" hours"
      exit(CRITICAL_STATE)
    elsif wnodes.length > 0
      puts "Warning :"+wnodes.join(',')+" did not check in for "+warning.to_s+" hours"
      exit(WARNING_STATE)
    elsif cnodes.length == 0 and wnodes.join(',') == 0
      puts "OK: All nodes are ok!"
      exit(OK_STATE)
    else
      puts "UNKNOWN"
      exit(UNKNOWN_STATE)
    end
  end
end
