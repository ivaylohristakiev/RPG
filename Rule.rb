require_relative 'Graph'

class Rule < Struct.new(:id, :l, :k, :r)
	def to_s
		"rule_#{id}"
	end

	def inspect
		"#{self}"
	end
	
	def isDangling?(graph,g)
		if l.nodes == k.nodes
			return true
		else
			# obtain g_n(L-K) in G
			deleted_nodes = (l.nodes - k.nodes).dup	# [1,2,3] - [1,2] = [3]
			g_deleted_nodes = []	
			deleted_nodes.each do |node|
				g_deleted_nodes.push(g.f_n[node])
			end
			
			# obtain g_e(L-K) in G
			deleted_edges = (l.edges - k.edges).dup
			g_deleted_edges = []
			deleted_edges.each do |edge|
				g_deleted_edges.push(g.f_e[edge])
			end			
			
			
		end
	end

	def matches(g)
		# empty graph matches in everything
	    if l.nodes.empty?
			true
	    elsif g.nodes.empty? 
			false	# non-empty never matches in empty
		end
		
		morphisms = []
		possible_matches = g.nodes.permutation(l.nodes.length).to_a	#possible injective matches for each node
		possible_matches.each do |match|
		
			#obtain f_n
 			node_mapping = {}
			l.nodes.each_with_index do |node,index|
				node_mapping = node_mapping.merge({node => match[index]})
			end
			
			
			possible_edges = g.edges.permutation(l.edges.length).to_a	#possible injective matches for each edge
			possible_edges.each do |edge_match|
				#obtain f_e
				edge_mapping = {}
				l.edges.each_with_index do |edge,index|
					edge_mapping = edge_mapping.merge({edge => edge_match[index]})
				end
				
				#mapping f = <f_n, f_e>
				f = Mapping.new(node_mapping, edge_mapping)
				
				#check mapping for morphism property
				valid = true
				l.edges.each do |e|
					g_s = f.f_n[e.s]
					g_t = f.f_n[e.t]
					g_e = f.f_e[e]
					if g_e.s != g_s  || g_e.t != g_t
						valid = false
						break
					end
				end
				
				# if a morphism, save it
				if valid == true
					morphisms.push(f)
				end				
			end			
		end
		
		return morphisms
	end
	
	def reduce(graph)
		if graph == nil
			return Fail.new
		end
	    results = []	# all possible result graphs H1, H2, ..
		morphisms = self.matches(graph)
		if morphisms.empty? 
			return Fail.new
		end
		
		morphisms.each do |f|			
			# For each match g, try to construct graph D together with morphism d: K -> D
			
			
			if l.nodes == k.nodes && l.edges == k.edges  # If K = L, then D = G
				d = Graph.new(graph.nodes.dup,graph.edges.dup)
			else
				
				# obtain g_n(L-K) in G
				deleted_nodes = (l.nodes - k.nodes).dup	# [1,2,3] - [1,2] = [3]
				g_deleted_nodes = []	
				deleted_nodes.each do |node|
					g_deleted_nodes.push(f.f_n[node])
				end
				
				# obtain g_e(L-K) in G
				deleted_edges = (l.edges - k.edges).dup
				g_deleted_edges = []
				deleted_edges.each do |edge|
					g_deleted_edges.push(f.f_e[edge])
				end unless deleted_edges == nil	
				
				# Construct D's nodes and edges
				d_nodes = (graph.nodes - g_deleted_nodes).dup		
				d_edges = (graph.edges - g_deleted_edges).dup
				
				# Check dangling condition, i.e. is D a graph
				not_a_graph = false
				d_edges.each do |e|
					if !d_nodes.include?(e.s) || !d_nodes.include?(e.t) # for each edge e, if e.s or e.t are not in D, then D is not a graph
						not_a_graph = true
						break	# stop edge checking
					end
				end unless d_edges.empty?
				
				if not_a_graph
					next # continue to next possible match
				end
				
				# Create D
				d = Graph.new(d_nodes,d_edges)
			end
			
			#construct morphism d: K -> D
			d_morph = Mapping.new(f.f_n,f.f_e)	# TODO: cheat, needs extra work, but h_n and h_e are called only on nodes in K

			# Try to construct H 
			added_nodes = r.nodes - k.nodes
			added_edges = r.edges - k.edges
			
			# Initialize H to D
			h_nodes = d.nodes.dup
			h_edges = d.edges.dup
			
			# Initialize h: R -> H from d : K -> D
			h_morph = Mapping.new(d_morph.f_n.dup,d_morph.f_e.dup)
			
			# For each node in R - K
			added_nodes.each do |n|
				# Create new node to be put in H
				new = Node.new()
				h_nodes.push(new)
				
				# update h_n
				h_morph.f_n = h_morph.f_n.merge({ n => new})
				
				# for each node in K
				k.nodes.each do |kn|
					# obtain edges in R from K to R-K
					r.edgesFromTo(kn,n).each do |e|
						# Create new edge to be put in H with source h_n(kn from K) and target h_n(n from R-K)
						new_e = Edge.new(h_morph.f_n[kn],h_morph.f_n[n])
						h_morph.f_e = h_morph.f_e.merge({e => new_e})
						h_edges.push(new_e)
					end
					
					# obtain edges in R from R-K to K
					r.edgesFromTo(n,kn).each do |e|
						# Create new edge to be put in H with source h_n(n from R-K) and target h_n(kn from K)
						new_e = Edge.new(h_morph.f_n[n],h_morph.f_n[kn])
						h_morph.f_e = h_morph.f_e.merge({e => new_e})
						h_edges.push(new_e)
					end					
				end 
				
				# obtain loop edges in R-K
				r.edgesFromTo(n,n).each do |e|
					# Create new edge representative with source and target in h(R-K)
					new_e = Edge.new(h_morph.f_n[n],h_morph.f_n[n])
					h_morph.f_e = h_morph.f_e.merge({e => new_e})
					h_edges.push(new_e)
				end							
			end 
			
			# Obtain edges from R-K to R-K
			added_nodes.each do |n|
				added_nodes.each do |other_n|
				
					if n == other_n # avoid loops
						next 
					end
					
					r.edgesFromTo(n,other_n).each do |e|
						new_e = Edge.new(h_morph.f_n[n],h_morph.f_n[other_n])
						h_morph.f_e = h_morph.f_e.merge({e => new_e})
						h_edges.push(new_e)					
					end
					
					r.edgesFromTo(other_n,n).each do |e|
						new_e = Edge.new(h_morph.f_n[other_n],h_morph.f_n[n])
						h_morph.f_e = h_morph.f_e.merge({e => new_e})
						h_edges.push(new_e)	
					end						
				end 
			end 
			
			# obtain edges in R-K with source and target in K
			#added_edges.each do |e|
			#	if k_nodes.include?(e.s) && k_nodes.include?(e.t)	# e.source and e.target are in K, then create edge h(source)->h(target)
			#		h_edges.push(Edge.new( h.f_n(e.s), h.f_n(e.t)))
			#	elsif k_nodes.include?(e.s) && !k_nodes.include?(e.t)	#e.source in K, e.target in R-K
			#		h_edges.push(Edge.new( h.f_n(e.s), Node.new()))
			#	elsif !k_nodes.include?(e.s) && k_nodes.include?(e.t)	#e.source in R-K, e.target in K
			#		h_edges.push(Edge.new( Node.new(), h.f_n(e.s)))
			#	else	#e.source in R-K, e.target in R-K
			#		h_edges.push(Edge.new( Node.new(), Node.new()))
			#	end
			#end unless added_edges == nil

			# Create H
			h_graph = Graph.new(h_nodes,h_edges)
			results.push(h_graph)
		end
		return [DoNothing.new, results.sample]
	end
	
	def reducible?
		true
	end
end