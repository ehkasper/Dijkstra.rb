# =====================================
# Eduardo H. Kasper - 0090462
# =====================================
class Edge
  attr_accessor :source, :dest, :length
  
  def initialize(source, dest)
    @source = source
    @dest = dest
  end
end

class Graph < Array
  attr_reader :edges

  def initialize
    @edges = []
  end
  
  def connect(source, dest)
    @edges.push Edge.new(source, dest)
  end
  
  def length_between(source, dest)
    @edges.each do |edge|
      return 1 if edge.source == source and edge.dest == dest
    end

    0
  end

  def neighbors(node)
    neighbors = []
    @edges.each do |edge|
      neighbors.push edge.dest if edge.source == node
    end

    neighbors.uniq
  end

  def get_closest_node nodes, distances
    nodes.inject do |x, y|
      next y unless distances[x]
      next x unless distances[y]
      next x if distances[x] < distances[y]
      y
    end
  end

  def dijkstra(source, dest)
    distances = {}

    self.each do |node|
      distances[node] = Float::INFINITY
    end

    distances[source] = 0

    nodes = self.clone

    until nodes.empty?
      closest_node = self.get_closest_node nodes, distances

      break unless distances[closest_node]
      
      return distances[dest] if closest_node == dest
      
      neighbors = nodes.neighbors(closest_node)

      neighbors.each do |node|
        candidate = distances[closest_node] + nodes.length_between(closest_node, node)

        if candidate < distances[node]
          distances[node] = candidate
        end
      end

      nodes.delete closest_node
    end

    return nil if dest

    distances
  end
end

file_lines = open(ARGV[0], "r").each_line
graph_file = file_lines.map { |l| l.split(",").map(&:to_i) }
elements = graph_file.first.length - 1

graph = Graph.new

for i in 0..(elements)
  graph.push i
end

def degree_centrality graph, i
  cont = 0
  graph.each_with_index do |line, source|
    line.each_with_index do |node, target|
      if source == i
        cont += 1 if node == 1
      else
        cont += 1 if target == i and node == 1
      end
    end
  end
  
  cont.to_f/(graph.first.length-1)
end

def closeness_centrality graph
  centralities = Array.new
  graph.each do |nodes|
    sum = 0
    nodes.each do |node|
      sum += node if node != Float::INFINITY
    end
    centralities.push (graph.first.length - 1).to_f / sum
  end

  centralities
end

graph_file.each_with_index do |line, source|
    line.each_with_index { |node, dest| graph.connect(source, dest) if node > 0 }
end

distances = Array.new
for i in 0..elements
  row = Array.new
  for dist in 0..elements
    row.push graph.dijkstra(i,  dist)
  end

  distances.push row
end

p "PC:"

closeness_centrality(distances).each_with_index do |centrality, node|
  p "#{node} => #{centrality}"
end

p ""
p "GC: "

distances.each_with_index do |line, source|
  p "#{source} => #{degree_centrality(distances, source)}"
end

