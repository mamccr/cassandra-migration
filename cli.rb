module Cli
	
	# returns value provided by the user
	def ask property_name, default_answer, description
		puts description
		print "#{property_name} #{default_answer.nil? ? '' : '|' + default_answer + '|'}: "
		return gets
	end

end