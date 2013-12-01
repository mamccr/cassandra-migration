$: << File.dirname(__FILE__)
require "cassandra_version"

# Determines the full set of migrations between a start and end point, and calculates the
# set of additional properties needed between those points
class Migrator

	STRING = "string"
	ARRAY = "array"
	NUMBER = "number"
	HASH = "hash"
	MIGRATIONS_DIR = "#{File.dirname(__FILE__)}/migrations"

	def initialize start_version, end_version
		@start_version = start_version
		@end_version = end_version
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
			if !in_range and (File::basename(migration) == "cassandra_#{@start_version}")
				in_range = true
			end
			if in_range and (File::basename(migration) == "cassandra_#{@end_version}")
				return applicable_migrations
			end
		end
	end

	def add_property name, type, default_value, description
		@added_properties << {name: name, type: type, default_value: default_value, description: description}
	end

	def remove_property name
		@removed_properties << name
	end

	# Determines what prompts must be removed and what prompts must be added to be able to migrate from start to finish
	def calculate_changes
		@added_properties = []
		@removed_properties = []
		all_migrations = find_all_migrations
		all_migrations.each do |migration_name|
			eval File.read(migration_name)
		end
	end

	# The list of properties that must be added to migrate from start to finish
	def added_properties
		return @added_properties unless @added_properties.nil?
		calculate_changes
		return @added_properties
	end

	# The list of properties that must be removed to migrate from start to finish
	def removed_properties
		return @removed_properties unless @removed_properties.nil?
		calculate_changes
		return @removed_properties
	end

end