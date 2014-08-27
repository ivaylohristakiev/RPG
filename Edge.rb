class Edge < Struct.new(:id, :s, :t, :l)
	@@edge_id = 0

	def initialize(s, t, l)
		@@edge_id = @@edge_id + 1
		super(@@edge_id, s, t, l)
	end
	
	def initialize(s, t)
		@@edge_id = @@edge_id + 1
		super(@@edge_id, s, t, 0)
	end
	
	def to_s
		"e_#{id}: (#{l})#{s.id}->#{t.id}"
	end

	def inspect
		"#{self}"
	end
	
end