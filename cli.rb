module Cli
	
	# simply adds the given statement to the interface
	def say statement
		puts statement
	end

	# returns value provided by the user
	def ask property_name, default_answer, description
		puts "\n" + description
		print "#{property_name} #{default_answer.nil? ? '' : '|' + default_answer + '|'}: "
		return gets
	end

end