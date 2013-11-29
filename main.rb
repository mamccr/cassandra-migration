$: << File.dirname(__FILE__)
require "trollop"

class Main

	def self.process_params
		opts = Trollop::options do
			version "cassandra_migrate version 1 (c) 2013 Steven Mark McCraw"
			banner <<-EOS
cassandra_migrate is a tool for migrating cassandra config files from one version to the next.
Usage:
cassandra_migrate [options]
[options] (all are required):
  EOS
  		opt :original_config, "The location of the current cassandra.yaml that needs to be updated", :type => String
  		opt :final_config, "The location to write the updated cassandra.yaml file", :type => String
  		opt :original_version, "The version of Cassandra to migrate from", :type => String
  		opt :final_version, "The version of Cassandra to migrate to", :type => String
		end
		if opts[:original_version].nil? or opts[:final_config].nil? or opts[:original_version].nil? or opts[:final_version].nil?
  		Trollop::die "Some options are missing"
  	end
  	Trollop::die :original_config, "must exist" unless File.exist?(opts[:original_config])
	end

end