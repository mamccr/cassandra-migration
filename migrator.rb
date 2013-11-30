$: << File.dirname(__FILE__)
require "cassandra_version"
require "cli"

# Determines the full set of migrations between a start and end point, and calculates the
# set of additional properties needed between those points
class Migrator

	# Implementation could vary here.  All that matters is that the module provide an ask
	# method with the same signature.
	include Cli
	
	STRING = "string"
	ARRAY = "array"
	NUMBER = "number"
	HASH = "hash"
	MIGRATIONS_DIR = "#{File.dirname(__FILE__)}/migrations"

	attr_reader :properties

	def initialize start_version, end_version
		@start_version = start_version
		@end_version = end_version
		@properties = []
		@answers = {}
	end

	# Returns the full set of migrations.  Assumes all migrations live in the migrations folder
	def find_all_migrations
		sorted_list = Dir.glob("#{MIGRATIONS_DIR}/**").sort do |file1, file2|
			CassandraVersion.new(File.basename(file1).split("_")[1]) <=> CassandraVersion.new(File.basename(file2).split("_")[1])
		end
		in_range = false
		applicable_migrations = []
		sorted_list.each do |migration|
			applicable_migrations << migration if in_range
			if !in_range and (migration == "Cassandra_#{@start_version}")
				in_range = true
			end
			if in_range and (migration == "Cassandra_#{@end_version}")
				return applicable_migrations
			end
		end
	end

	def add_property name, type, default_value, description
		@properties << {name: name, type: type, default_value: default_value, description: description}
	end

	def remove_property name
		# TODO
	end

	# Populates @properties with the prompts required to be able to migrate from start to finish
	def gather_added_properties
		all_migrations = find_all_migrations
		all_migrations.each do |migration_name|
			eval File.read(migration_name)
		end
	end

	# collects values for all new properties
	def human_answers
		gather_added_properties
		@properties.each do |property|
			name = property[:name]
			@answers[name] = ask(name, property[:default_value], property[:description])
		end
	end

end