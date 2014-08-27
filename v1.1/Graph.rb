require './Edge.rb'
require './Node.rb'

class Graph < Struct.new(:nodes,:edges)
	def hasNode?(node)
		nodes.member?(node)	
	end

	def outgoingEdgesOf(node)
		result = []
		edges.each do |e|
			if e.s == node
				result.push(e)
			end
		end
		return result
	end

	def incomingEdgesOf(node)
		result = []
		edges.each do |e|
			if e.t == node
				result.push(e)
			end
		end
		return result
	end

	def edgesFromTo(from,to)
		result = []
		edges.each do |e|
			if e.s == from && e.t == to
				result.push(e)
			end
		end
		return result
	end

	def to_s
		"{nodes: #{nodes.inspect}, edges: #{edges.inspect}}"
	end

	def inspect
		"#{self}"
	end

end
