$: << File.dirname(__FILE__)
require "trollop"
require "migrator"

# Contains the central control logic for the migration.  Parses user input from the command line
# and delegates tasks to other helpers.
class Main

	MISSING_OPTION = "Some options are missing"
	MISSING_FILE = "could not be found.  Please make sure the file exists"
	MISSING_MIGRATION = "No migration data for version"
	MIGRATIONS_DIR = "#{File.dirname(__FILE__)}/migrations"

	# verifies that migrations can be found for the to and from versions
	def identify_migrations
		orig = "cassandra_#{@opts[:original_version]}"
		Trollop::die "#{MISSING_MIGRATION} #{orig}" unless File.exists? "#{MIGRATIONS_DIR}/#{orig}"

		final = "cassandra_#{@opts[:final_version]}"
		Trollop::die "#{MISSING_MIGRATION} #{final}" unless File.exists? "#{MIGRATIONS_DIR}/#{final}"
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
		if @opts[:original_config].nil? or 
			 @opts[:final_config].nil? or 
			 @opts[:original_version].nil? or 
			 @opts[:final_version].nil?
  		Trollop::die MISSING_OPTION
  	end
  	Trollop::die "#{@opts[:original_config]} #{MISSING_FILE}" unless File.exist?(@opts[:original_config])
	end

	# Highest level orchestration of program flow
	def run
		process_params
		identify_migrations
		migrator = Migrator.new(@opts[:original_version], @opts[:final_version])
		puts ">>>>>>>#{migrator.human_answers}"
	end

end