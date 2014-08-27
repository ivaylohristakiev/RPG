class Fail	
	def to_s
		'fail'
	end
	
	def inspect
		"#{self}"
	end
	
	def ==(other)
		other.instance_of?(Fail)
	end
	
	def reducible?
		false
	end
end