require_relative 'Mapping.rb'
require_relative 'Node.rb'
require_relative 'Edge.rb'
require_relative 'Ruleset.rb'
require_relative 'Rule.rb'
require_relative 'Graph.rb'
require_relative 'Seq.rb'
require_relative 'IfThenElse.rb'
require_relative 'Alap.rb'
require_relative 'RuleSet.rb'

class GP < Struct.new(:com_sq,:graph)
	def to_s
		"#{com_sq} ++ #{graph}"
	end

	def inspect
		"#{self}"
	end
	
	def step
		self.com_sq, self.graph = com_sq.reduce(graph)
	end
	
	def run
		while com_sq.reducible?
			puts "~PROG: #{com_sq}\n ~GRAPH: #{graph}"
			step
		end
		puts "~PROG: #{com_sq}\n ~GRAPH: #{graph}"
	end	
end


