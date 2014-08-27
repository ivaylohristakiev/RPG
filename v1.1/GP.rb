require './Mapping.rb'
require './Node.rb'
require './Edge.rb'
require './Rule.rb'
require './Graph.rb'
require './Seq.rb'
require './IfThenElse.rb'
require './Alap.rb'
require './RuleSet.rb'

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
			puts "~PROG: #{com_sq}\n~GRAPH: #{graph}"
			step
		end
		case com_sq		
		when Fail.new 
				puts "Fail"
		else
				puts "##RESULT: #{graph}"
		end
	end	
end


