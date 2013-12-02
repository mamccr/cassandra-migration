module Cli
	
	LINE_WIDTH = 80

	# Constrains text to a given width
	def self.wrap(text, width)
		# match the first width characters which are followed by some spaces or a newline
		# over and over, then tack on whatever is left.
		text.gsub(/(.{1,#{width}})( +|$\n?)|(.{1,#{width}})/, "\\1\\3\n").rstrip
	end

	# simply adds the given statement to the interface
	def say statement
		puts Cli.wrap(statement, LINE_WIDTH)
	end

	# returns value provided by the user
	def ask property_name, default_answer, description
		puts "\n#{Cli.wrap(description, LINE_WIDTH)}\n"
		print "#{property_name} #{default_answer.nil? ? '' : "|#{default_answer}|"}: "
		answer = gets.chomp
		if answer.length == 0 and !default_answer.nil?
			answer = default_answer
		end
		return answer
	end

end