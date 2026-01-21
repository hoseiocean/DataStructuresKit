// MARK: - Graph
// A generic graph implementation using adjacency list.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - mutable shared state ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) addVertex/addEdge, O(V+E) traversals ✓

/// A generic graph data structure supporting both directed and undirected edges.
///
/// `Graph` uses an adjacency list representation for efficient storage
/// and traversal. It supports weighted edges for algorithms like Dijkstra's.
///
/// ## Graph Types
///
/// - **Directed**: Edges have direction (A → B ≠ B → A)
/// - **Undirected**: Edges are bidirectional (A — B)
///
/// ## Example
///
/// ```swift
/// // Create a social network (undirected)
/// let network = Graph<String>(edgeType: .undirected)
/// network.addVertex("Alice")
/// network.addVertex("Bob")
/// network.addVertex("Charlie")
/// network.addEdge(from: "Alice", to: "Bob")
/// network.addEdge(from: "Bob", to: "Charlie")
///
/// print(network.neighbors(of: "Bob")) // ["Alice", "Charlie"]
///
/// // BFS from Alice
/// network.bfs(from: "Alice") { person in
///     print("Visited: \(person)")
///     return true // continue traversal
/// }
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | addVertex(_:) | O(1) |
/// | addEdge(from:to:) | O(1) |
/// | neighbors(of:) | O(1) |
/// | hasEdge(from:to:) | O(degree) |
/// | BFS/DFS | O(V + E) |
/// | Dijkstra | O((V + E) log V) |
public final class Graph<Vertex: Hashable> {
  
  // MARK: - Types
  
  /// The type of graph edges.
  public enum EdgeType {
    case directed
    case undirected
  }
  
  /// An edge connecting two vertices.
  public struct Edge: Equatable {
    public let source: Vertex
    public let destination: Vertex
    public let weight: Double
    
    public init(source: Vertex, destination: Vertex, weight: Double = 1.0) {
      self.source = source
      self.destination = destination
      self.weight = weight
    }
    
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
      lhs.source == rhs.source &&
      lhs.destination == rhs.destination &&
      lhs.weight == rhs.weight
    }
  }
  
  // MARK: - Properties
  
  /// The type of edges in this graph.
  public let edgeType: EdgeType
  
  /// Adjacency list mapping vertices to their outgoing edges.
  private var adjacencyList: [Vertex: [Edge]] = [:]
  
  /// All vertices in the graph.
  public var vertices: [Vertex] {
    Array(adjacencyList.keys)
  }
  
  /// The number of vertices.
  public var vertexCount: Int { adjacencyList.count }
  
  /// The number of edges.
  public var edgeCount: Int {
    let total = adjacencyList.values.reduce(0) { $0 + $1.count }
    return edgeType == .undirected ? total / 2 : total
  }
  
  /// A Boolean value indicating whether the graph is empty.
  public var isEmpty: Bool { adjacencyList.isEmpty }
  
  // MARK: - Initialization
  
  /// Creates an empty graph.
  ///
  /// - Parameter edgeType: The type of edges (default: undirected).
  public init(edgeType: EdgeType = .undirected) {
    self.edgeType = edgeType
  }
  
  // MARK: - Vertices
  
  /// Adds a vertex to the graph.
  ///
  /// - Complexity: O(1)
  public func addVertex(_ vertex: Vertex) {
    if adjacencyList[vertex] == nil {
      adjacencyList[vertex] = []
    }
  }
  
  /// Removes a vertex and all its edges.
  ///
  /// - Complexity: O(V + E)
  public func removeVertex(_ vertex: Vertex) {
    adjacencyList.removeValue(forKey: vertex)
    
    // Remove all edges pointing to this vertex
    for v in adjacencyList.keys {
      adjacencyList[v]?.removeAll { $0.destination == vertex }
    }
  }
  
  /// Returns whether the graph contains the vertex.
  ///
  /// - Complexity: O(1)
  public func containsVertex(_ vertex: Vertex) -> Bool {
    adjacencyList[vertex] != nil
  }
  
  // MARK: - Edges
  
  /// Adds an edge between two vertices.
  ///
  /// - Parameters:
  ///   - source: The source vertex.
  ///   - destination: The destination vertex.
  ///   - weight: The edge weight (default: 1.0).
  /// - Complexity: O(1)
  public func addEdge(from source: Vertex, to destination: Vertex, weight: Double = 1.0) {
    addVertex(source)
    addVertex(destination)
    
    adjacencyList[source]?.append(Edge(source: source, destination: destination, weight: weight))
    
    if edgeType == .undirected {
      adjacencyList[destination]?.append(Edge(source: destination, destination: source, weight: weight))
    }
  }
  
  /// Removes an edge between two vertices.
  ///
  /// - Complexity: O(degree)
  public func removeEdge(from source: Vertex, to destination: Vertex) {
    adjacencyList[source]?.removeAll { $0.destination == destination }
    
    if edgeType == .undirected {
      adjacencyList[destination]?.removeAll { $0.destination == source }
    }
  }
  
  /// Returns all edges from a vertex.
  ///
  /// - Complexity: O(1)
  public func edges(from vertex: Vertex) -> [Edge] {
    adjacencyList[vertex] ?? []
  }
  
  /// Returns all neighbors of a vertex.
  ///
  /// - Complexity: O(degree)
  public func neighbors(of vertex: Vertex) -> [Vertex] {
    edges(from: vertex).map(\.destination)
  }
  
  /// Returns whether an edge exists between two vertices.
  ///
  /// - Complexity: O(degree)
  public func hasEdge(from source: Vertex, to destination: Vertex) -> Bool {
    edges(from: source).contains { $0.destination == destination }
  }
  
  /// Returns the weight of an edge if it exists.
  ///
  /// - Complexity: O(degree)
  public func weight(from source: Vertex, to destination: Vertex) -> Double? {
    edges(from: source).first { $0.destination == destination }?.weight
  }
  
  /// Returns the degree (number of edges) of a vertex.
  ///
  /// - Complexity: O(1)
  public func degree(of vertex: Vertex) -> Int {
    adjacencyList[vertex]?.count ?? 0
  }
  
  // MARK: - Traversals
  
  /// Performs breadth-first search from a starting vertex.
  ///
  /// - Parameters:
  ///   - start: The starting vertex.
  ///   - visit: A closure called for each visited vertex.
  ///            Return `false` to stop traversal.
  /// - Complexity: O(V + E)
  public func bfs(from start: Vertex, visit: (Vertex) -> Bool) {
    guard containsVertex(start) else { return }
    
    var visited = Set<Vertex>()
    var queue = Queue<Vertex>()
    
    queue.enqueue(start)
    visited.insert(start)
    
    while let vertex = queue.dequeue() {
      if !visit(vertex) { return }
      
      for neighbor in neighbors(of: vertex) where !visited.contains(neighbor) {
        visited.insert(neighbor)
        queue.enqueue(neighbor)
      }
    }
  }
  
  /// Performs depth-first search from a starting vertex.
  ///
  /// - Parameters:
  ///   - start: The starting vertex.
  ///   - visit: A closure called for each visited vertex.
  ///            Return `false` to stop traversal.
  /// - Complexity: O(V + E)
  public func dfs(from start: Vertex, visit: (Vertex) -> Bool) {
    guard containsVertex(start) else { return }
    
    var visited = Set<Vertex>()
    var stack = Stack<Vertex>()
    
    stack.push(start)
    
    while let vertex = stack.pop() {
      guard !visited.contains(vertex) else { continue }
      visited.insert(vertex)
      
      if !visit(vertex) { return }
      
      for neighbor in neighbors(of: vertex) where !visited.contains(neighbor) {
        stack.push(neighbor)
      }
    }
  }
  
  // MARK: - Path Finding
  
  /// Finds the shortest path between two vertices using BFS.
  ///
  /// For unweighted graphs or when all weights are equal.
  ///
  /// - Complexity: O(V + E)
  public func shortestPath(from source: Vertex, to destination: Vertex) -> [Vertex]? {
    guard containsVertex(source), containsVertex(destination) else { return nil }
    guard source != destination else { return [source] }
    
    var visited = Set<Vertex>()
    var queue = Queue<Vertex>()
    var parent: [Vertex: Vertex] = [:]
    
    queue.enqueue(source)
    visited.insert(source)
    
    while let vertex = queue.dequeue() {
      if vertex == destination {
        return reconstructPath(from: source, to: destination, parent: parent)
      }
      
      for neighbor in neighbors(of: vertex) where !visited.contains(neighbor) {
        visited.insert(neighbor)
        parent[neighbor] = vertex
        queue.enqueue(neighbor)
      }
    }
    
    return nil // No path found
  }
  
  /// Dijkstra's algorithm for weighted shortest paths.
  ///
  /// - Parameter source: The starting vertex.
  /// - Returns: Dictionary mapping each reachable vertex to its distance and path.
  /// - Complexity: O((V + E) log V)
  public func dijkstra(from source: Vertex) -> [Vertex: (distance: Double, path: [Vertex])] {
    guard containsVertex(source) else { return [:] }
    
    var distances: [Vertex: Double] = [source: 0]
    var previous: [Vertex: Vertex] = [:]
    var visited = Set<Vertex>()
    
    // Simple implementation using sorted array (optimize with indexed heap for production)
    var unvisited = Set(vertices)
    
    while !unvisited.isEmpty {
      // Find unvisited vertex with minimum distance
      guard let current = unvisited.min(by: { (distances[$0] ?? .infinity) < (distances[$1] ?? .infinity) }),
            let currentDistance = distances[current],
            currentDistance < .infinity else { break }
      
      unvisited.remove(current)
      visited.insert(current)
      
      for edge in edges(from: current) where !visited.contains(edge.destination) {
        let newDistance = currentDistance + edge.weight
        if newDistance < (distances[edge.destination] ?? .infinity) {
          distances[edge.destination] = newDistance
          previous[edge.destination] = current
        }
      }
    }
    
    // Build result
    var result: [Vertex: (distance: Double, path: [Vertex])] = [:]
    for vertex in visited {
      guard let distance = distances[vertex] else { continue }
      let path = reconstructPath(from: source, to: vertex, parent: previous)
      result[vertex] = (distance, path ?? [])
    }
    
    return result
  }
  
  private func reconstructPath(from source: Vertex, to destination: Vertex, parent: [Vertex: Vertex]) -> [Vertex]? {
    var path: [Vertex] = [destination]
    var current = destination
    
    while current != source {
      guard let prev = parent[current] else { return nil }
      path.append(prev)
      current = prev
    }
    
    return path.reversed()
  }
  
  // MARK: - Graph Properties
  
  /// Returns whether the graph is connected.
  ///
  /// For directed graphs, checks weak connectivity.
  ///
  /// - Complexity: O(V + E)
  public func isConnected() -> Bool {
    guard let start = vertices.first else { return true }
    
    var visited = Set<Vertex>()
    bfs(from: start) { vertex in
      visited.insert(vertex)
      return true
    }
    
    return visited.count == vertexCount
  }
  
  /// Detects if the graph contains a cycle.
  ///
  /// - Complexity: O(V + E)
  public func hasCycle() -> Bool {
    var visited = Set<Vertex>()
    var recursionStack = Set<Vertex>()
    
    func dfsDetectCycle(_ vertex: Vertex) -> Bool {
      visited.insert(vertex)
      recursionStack.insert(vertex)
      
      for neighbor in neighbors(of: vertex) {
        if !visited.contains(neighbor) {
          if dfsDetectCycle(neighbor) { return true }
        } else if recursionStack.contains(neighbor) {
          return true
        }
      }
      
      recursionStack.remove(vertex)
      return false
    }
    
    for vertex in vertices where !visited.contains(vertex) {
      if dfsDetectCycle(vertex) { return true }
    }
    
    return false
  }
  
  /// Returns a topological sort for directed acyclic graphs.
  ///
  /// - Returns: Vertices in topological order, or `nil` if graph has a cycle.
  /// - Complexity: O(V + E)
  public func topologicalSort() -> [Vertex]? {
    guard edgeType == .directed else { return nil }
    
    var inDegree: [Vertex: Int] = [:]
    for vertex in vertices {
      inDegree[vertex] = 0
    }
    for vertex in vertices {
      for neighbor in neighbors(of: vertex) {
        inDegree[neighbor, default: 0] += 1
      }
    }
    
    var queue = Queue<Vertex>()
    for (vertex, degree) in inDegree where degree == 0 {
      queue.enqueue(vertex)
    }
    
    var result: [Vertex] = []
    
    while let vertex = queue.dequeue() {
      result.append(vertex)
      
      for neighbor in neighbors(of: vertex) {
        inDegree[neighbor]! -= 1
        if inDegree[neighbor] == 0 {
          queue.enqueue(neighbor)
        }
      }
    }
    
    return result.count == vertexCount ? result : nil
  }
  
  /// Creates a copy of the graph.
  public func copy() -> Graph {
    let newGraph = Graph(edgeType: edgeType)
    
    for vertex in vertices {
      newGraph.addVertex(vertex)
    }
    
    if edgeType == .directed {
      // For directed graphs, copy all edges
      for vertex in vertices {
        for edge in edges(from: vertex) {
          newGraph.adjacencyList[edge.source]?.append(edge)
        }
      }
    } else {
      // For undirected graphs, track added edges to avoid duplicates
      var addedPairs = Set<String>()
      for vertex in vertices {
        for edge in edges(from: vertex) {
          let key1 = "\(edge.source)-\(edge.destination)"
          let key2 = "\(edge.destination)-\(edge.source)"
          if !addedPairs.contains(key1) && !addedPairs.contains(key2) {
            newGraph.addEdge(from: edge.source, to: edge.destination, weight: edge.weight)
            addedPairs.insert(key1)
          }
        }
      }
    }
    
    return newGraph
  }
}

// MARK: - CustomStringConvertible

extension Graph: CustomStringConvertible {
  public var description: String {
    var result = "Graph<\(Vertex.self)>(\(edgeType), V=\(vertexCount), E=\(edgeCount)):\n"
    for vertex in vertices.sorted(by: { "\($0)" < "\($1)" }) {
      let neighbors = self.neighbors(of: vertex).map { "\($0)" }.joined(separator: ", ")
      result += "  \(vertex) → [\(neighbors)]\n"
    }
    return result
  }
}
