n1 = Node.new ; n2 = Node.new ; n3 = Node.new ; n4 = Node.new ; n5 = Node.new ; n6 = Node.new
e1 = Edge.new( n1, n1); e2 = Edge.new( n3, n3); e3 = Edge.new( n4, n4); e4 = Edge.new( n6, n5)
g1 = Graph.new([n3, n4], [e2, e3])
l = Graph.new([n1,n2], [e1])
k = Graph.new([n1], [e1])
r = Graph.new([n1,n5,n6], [e1,e4])
r1 = Rule.new(:nothing, l, k, k)
prog = r1
gp = GP.new(prog, g1)