class Mapping < Struct.new(:f_n, :f_e)	
	def to_s
		"~#{f_n.inspect}~#{f_e.inspect}~"
	end

	def inspect
		"#{self}"
	end
end