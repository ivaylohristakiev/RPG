require_relative 'Fail.rb'

class IfThenElse < Struct.new(:cond, :yes, :no)
	def to_s
		"if ( #{cond} ) then #{yes} else #{no}"
	end

	def inspect
		"#{self}"
	end

	def reduce(graph)
		if cond.reducible?
			[IfThenElse.new(cond.reduce(graph), yes, no), graph]
		else
			case cond
			when Fail.new
				[no, graph]
			else
				[yes, graph]
			end
		end
	end
	
	def reducible?
		true
	end
end