require './Fail.rb'
require './DoNothing.rb'

class Alap < Struct.new(:prog)
	def to_s
		"#{prog}!"
	end

	def inspect
		"#{self}"
	end

	def reduce(graph)
		if prog.reducible?
			reduced_prog, reduced_graph = prog.reduce(graph)
			case reduced_prog
			when Fail.new
				[DoNothing.new, graph]
			else
				[Alap.new(prog), reduced_graph]
			end
		else
			case prog
			when Fail.new
				[Fail.new, graph]
			when DoNothing.new
				[DoNothing.new, graph]				
			end
		end
	end
	
	def reducible?
		true
	end
end
