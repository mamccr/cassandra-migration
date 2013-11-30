$: << File.dirname(__FILE__)
require "trollop"

# Contains the central control logic for the migration.  Parses user input from the command line
# and delegates tasks to other helpers.
class Main

	MISSING_OPTION = "Some options are missing"
	MISSING_FILE = "could not be found.  Please make sure the file exists"
	MISSING_MIGRATION = "No migration data for version"

	# verifies that migrations can be found for the to and from versions
	def identify_migrations
		orig = @opts[:original_version]
		begin
			load "migrations/cassandra_#{orig}"
		rescue LoadError
			Trollop::die "#{MISSING_MIGRATION} #{orig}"
		end

		final = @opts[:final_version]
		begin
			load "migrations/cassandra_#{final}"
		rescue LoadError
			Trollop::die "#{MISSING_MIGRATION} #{final}"
		end
	end

	# parses command line options and stores them in @opts
	def process_params
		@opts = Trollop::options do
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
		if !@opts.include? :original_config or 
			 !@opts.include? :final_config or 
			 !@opts.include? :original_version or 
			 !@opts.include? :final_version
  		Trollop::die MISSING_OPTION
  	end
  	Trollop::die "#{@opts[:original_config]} #{MISSING_FILE}" unless File.exist?(@opts[:original_config])
	end

	# Highest level orchestration of program flow
	def run
		process_params
		identify_migrations
	end

end