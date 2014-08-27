class Node < Struct.new(:id, :l)
	@@node_id = 0

	def initialize(label)
		@@node_id = @@node_id + 1
		super(@@node_id, label)
	end
	
	def initialize
		@@node_id = @@node_id + 1
		super(@@node_id, 0)
	end

	def to_s
		"(#{id}:#{l})"
	end

	def inspect
		"#{self}"
	end

end