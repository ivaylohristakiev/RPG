require './Fail.rb'

class Seq < Struct.new(:seq1, :seq2)
	def to_s
		"#{seq1}; #{seq2}"
	end

	def inspect
		"#{self}"
	end

	def reduce(graph)
		case seq1
		when DoNothing.new
			[seq2, graph]
		when Fail.new
			[Fail.new, graph]
		else
			reduced_seq1, reduced_graph = seq1.reduce(graph)
			[Seq.new(reduced_seq1, seq2), reduced_graph]	
		end
	end
	
	def reducible?
		true
	end
end
