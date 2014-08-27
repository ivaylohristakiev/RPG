require_relative 'Rule.rb'
require_relative 'Fail.rb'
require_relative 'DoNothing.rb'

class RuleSet < Struct.new(:set)
	def to_s
		"{#{set}}"
	end

	def inspect
		"#{self}\n"
	end

	def reduce(graph)
		results = []
		set.each do |rule|
			result = rule.apply(graph)
			if result == Fail.new
				next
			end
			results.push(result)
		end
		
		if results.empty?
			[Fail.new, graph]
		else
			[DoNothing.new, results.sample] # pick a random H
		end
	end	
	
	def reducible?
		false
	end
end