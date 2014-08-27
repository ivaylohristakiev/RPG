class Number < Struct.new(:value)
	def to_s
		value.to_s
	end

	def inspect
		"#{self}"
	end

	def reducible?
		false
	end
end

class Boolean < Struct.new(:value)
	def to_s
		value.to_s
	end

	def inspect
		"#{self}"
	end

	def reducible?
		false
	end
end

class LessThan < Struct.new(:left,:right)
	def to_s
		"#{left} < #{right}"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		if left.reducible?
			LessThan.new(left.reduce(env), right)
		elsif right.reducible?
			LessThan.new(left, right.reduce(env))
		else
			Boolean.new(left.value < right.value)
		end
	end
end

class Add < Struct.new(:left,:right)
	def to_s
		"#{left} + #{right}"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		if left.reducible?
			Add.new(left.reduce(env), right)
		elsif right.reducible?
			Add.new(left, right.reduce(env))
		else
			Number.new(left.value + right.value)
		end
	end
end

class Multiply < Struct.new(:left,:right)
	def to_s
		"#{left} * #{right}"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		if left.reducible?
			Multiply.new(left.reduce(env), right)
		elsif right.reducible?
			Multiply.new(left, right.reduce(env))
		else
			Number.new(left.value * right.value)
		end
	end
end



class Machine <Struct.new(:st,:env)
	def step
		self.st, self.env = st.reduce(env)
	end
	
	def run
		while st.reducible?
			puts "#{st} -- #{env.inspect}" 
			step
		end
		puts "#{st} -- #{env.inspect}"
	end
end

class Variable < Struct.new(:name)
	def to_s
		name.to_s
	end

	def inspect
		"#{self}"
	end

	def reducible?
		true
	end

	def reduce(env)
		env[name.to_s]
	end
end

class DoNothing
	def to_s
		'do-nothing'
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		false
	end

	def ==(other)
		other.instance_of?(DoNothing)
	end	
end

class Assign < Struct.new(:name, :exp)
	def to_s
		"#{name} = #{exp}"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		if exp.reducible?
			[Assign.new(name, exp.reduce(env)), env]
		else
			[DoNothing.new, env.merge({ "#{name.to_s}" => exp })]
		end
	end
end

class If < Struct.new(:c,:yes,:no)
	def to_s
		"if (#{c}) then { #{yes} } else { #{no} }"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		if c.reducible?
			[If.new(c.reduce(env), yes, no),env]
		else
			case c
			when Boolean.new(true)
				[yes,env]
			when Boolean.new(false)
				[no,env]
			end
		end
	end
end

class Sequence < Struct.new(:f,:s)
	def to_s
		"#{f}; #{s}"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		case f
		when DoNothing.new
			[s, env]
		else
			reduced, new_env = f.reduce(env)			
			[Sequence.new(reduced,s),new_env]
		end
	end
end



class While < Struct.new(:c,:body)
	def to_s
		"while (#{c}) do { #{body} }"
	end

	def inspect
		"<<#{self}>>"
	end

	def reducible?
		true
	end

	def reduce(env)
		[If.new(c,Sequence.new(body,self),DoNothing.new),env]
	end
end


st1 = If.new( Variable.new(:z), Assign.new(Variable.new(:y),Add.new(Variable.new(:x), Variable.new(:y))), Assign.new(Variable.new(:y),Add.new(Variable.new(:y), Variable.new(:y))))
st2 = Sequence.new( 
		Assign.new(Variable.new(:x), Add.new(Variable.new(:x), Number.new(5))),		
		Assign.new(Variable.new(:y), Add.new(Variable.new(:x), Number.new(5)))
)
st3 = While.new(LessThan.new(Variable.new(:x), Number.new(12)),Assign.new(Variable.new(:x), Multiply.new(Variable.new(:x), Number.new(3))))
env1 = { "z" => Boolean.new(true), "x" => Number.new(3), "y" => Number.new(5)}
env2 = { "x" => Number.new(1)}
m = Machine.new(st3,env2)
