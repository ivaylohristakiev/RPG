require './Rule.rb'
require './Fail.rb'
require './DoNothing.rb'

class RuleSet < Struct.new(:set)
	def to_s
		result = "{ "
		set.each { |r| result << r.to_s + ", "}
		result = result[0..-3] unless set.empty?
		result << "}"
		return result
	end

	def inspect
		"#{self}\n"
	end

	def reduce(graph)
		results = []
		# Nondeterministic on rule order
		set.shuffle.each do |rule|
			result, reduced_graph = rule.apply(graph)
			if result == Fail.new
				next
			end
			results.push(reduced_graph)
		end
		
		if results.empty?
			[Fail.new, graph]
		else
			[DoNothing.new, results.sample] # pick a random H
		end
	end	
	
	def reducible?
		true
	end
end
