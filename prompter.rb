$: << File.dirname(__FILE__)
require "cli"

# Handles presentation of properties that need values to a human user.
class Prompter
	
	# Implementation could vary here.  All that matters is that the module provide an ask
	# and say method with the same signatures.
	include Cli
	
	def initialize
		say ("*" * 80) + "Congratulations on upgrading Cassandra!  A few configuration options have changed. \
For each new option given below, please read the description preceeding the prompt and enter the value you \
want the property to have.  For options that have a |default answer|, you can just hit enter to accept the default."
		say "*" * 80
	end

	# collects values for all new properties
	def human_answers added_properties
		answers = {}
		added_properties.each do |property|
			name = property[:name]
			answers[name] = ask(name, property[:default_value], property[:description])
		end
		return answers
	end


end