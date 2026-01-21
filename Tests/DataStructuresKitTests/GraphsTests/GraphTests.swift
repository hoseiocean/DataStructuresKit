import Testing
@testable import DataStructuresKit

@Suite("Graph Tests")
struct GraphTests {
  
  // MARK: - Initialization
  
  @Test("Empty graph")
  func testEmptyGraph() {
    let graph = Graph<String>()
    
    #expect(graph.isEmpty)
    #expect(graph.vertexCount == 0)
    #expect(graph.edgeCount == 0)
  }
  
  // MARK: - Vertices
  
  @Test("Add vertex")
  func testAddVertex() {
    let graph = Graph<String>()
    
    graph.addVertex("A")
    graph.addVertex("B")
    
    #expect(graph.vertexCount == 2)
    #expect(graph.containsVertex("A"))
    #expect(graph.containsVertex("B"))
  }
  
  @Test("Remove vertex")
  func testRemoveVertex() {
    let graph = Graph<String>()
    
    graph.addEdge(from: "A", to: "B")
    graph.addEdge(from: "B", to: "C")
    graph.removeVertex("B")
    
    #expect(!graph.containsVertex("B"))
    #expect(graph.neighbors(of: "A").isEmpty)
  }
  
  // MARK: - Undirected Edges
  
  @Test("Undirected edge")
  func testUndirectedEdge() {
    let graph = Graph<String>(edgeType: .undirected)
    
    graph.addEdge(from: "A", to: "B")
    
    #expect(graph.hasEdge(from: "A", to: "B"))
    #expect(graph.hasEdge(from: "B", to: "A"))
    #expect(graph.edgeCount == 1)
  }
  
  @Test("Undirected neighbors")
  func testUndirectedNeighbors() {
    let graph = Graph<String>(edgeType: .undirected)
    
    graph.addEdge(from: "A", to: "B")
    graph.addEdge(from: "A", to: "C")
    
    #expect(Set(graph.neighbors(of: "A")) == Set(["B", "C"]))
    #expect(graph.neighbors(of: "B") == ["A"])
  }
  
  // MARK: - Directed Edges
  
  @Test("Directed edge")
  func testDirectedEdge() {
    let graph = Graph<String>(edgeType: .directed)
    
    graph.addEdge(from: "A", to: "B")
    
    #expect(graph.hasEdge(from: "A", to: "B"))
    #expect(!graph.hasEdge(from: "B", to: "A"))
    #expect(graph.edgeCount == 1)
  }
  
  // MARK: - Weighted Edges
  
  @Test("Edge weights")
  func testEdgeWeights() {
    let graph = Graph<String>()
    
    graph.addEdge(from: "A", to: "B", weight: 5.0)
    graph.addEdge(from: "A", to: "C", weight: 3.0)
    
    #expect(graph.weight(from: "A", to: "B") == 5.0)
    #expect(graph.weight(from: "A", to: "C") == 3.0)
    #expect(graph.weight(from: "A", to: "D") == nil)
  }
  
  // MARK: - BFS
  
  @Test("BFS traversal")
  func testBFS() {
    let graph = Graph<Int>()
    
    graph.addEdge(from: 1, to: 2)
    graph.addEdge(from: 1, to: 3)
    graph.addEdge(from: 2, to: 4)
    graph.addEdge(from: 3, to: 4)
    
    var visited: [Int] = []
    graph.bfs(from: 1) { vertex in
      visited.append(vertex)
      return true
    }
    
    #expect(visited.first == 1)
    #expect(visited.count == 4)
  }
  
  @Test("BFS early termination")
  func testBFSEarlyTermination() {
    let graph = Graph<Int>()
    
    graph.addEdge(from: 1, to: 2)
    graph.addEdge(from: 2, to: 3)
    graph.addEdge(from: 3, to: 4)
    
    var visited: [Int] = []
    graph.bfs(from: 1) { vertex in
      visited.append(vertex)
      return vertex != 2  // Stop at 2
    }
    
    #expect(visited == [1, 2])
  }
  
  // MARK: - DFS
  
  @Test("DFS traversal")
  func testDFS() {
    let graph = Graph<Int>()
    
    graph.addEdge(from: 1, to: 2)
    graph.addEdge(from: 1, to: 3)
    graph.addEdge(from: 2, to: 4)
    
    var visited: [Int] = []
    graph.dfs(from: 1) { vertex in
      visited.append(vertex)
      return true
    }
    
    #expect(visited.first == 1)
    #expect(visited.count == 4)
  }
  
  // MARK: - Shortest Path
  
  @Test("Shortest path BFS")
  func testShortestPathBFS() {
    let graph = Graph<String>()
    
    graph.addEdge(from: "A", to: "B")
    graph.addEdge(from: "B", to: "C")
    graph.addEdge(from: "A", to: "D")
    graph.addEdge(from: "D", to: "C")
    
    let path = graph.shortestPath(from: "A", to: "C")
    
    #expect(path != nil)
    #expect(path?.count == 3)  // A -> B -> C or A -> D -> C
    #expect(path?.first == "A")
    #expect(path?.last == "C")
  }
  
  @Test("No path exists")
  func testNoPath() {
    let graph = Graph<String>()
    
    graph.addVertex("A")
    graph.addVertex("B")  // Disconnected
    
    let path = graph.shortestPath(from: "A", to: "B")
    
    #expect(path == nil)
  }
  
  // MARK: - Dijkstra
  
  @Test("Dijkstra shortest paths")
  func testDijkstra() {
    let graph = Graph<String>(edgeType: .directed)
    
    graph.addEdge(from: "A", to: "B", weight: 1)
    graph.addEdge(from: "A", to: "C", weight: 4)
    graph.addEdge(from: "B", to: "C", weight: 2)
    graph.addEdge(from: "B", to: "D", weight: 5)
    graph.addEdge(from: "C", to: "D", weight: 1)
    
    let results = graph.dijkstra(from: "A")
    
    #expect(results["A"]?.distance == 0)
    #expect(results["B"]?.distance == 1)
    #expect(results["C"]?.distance == 3)  // A -> B -> C
    #expect(results["D"]?.distance == 4)  // A -> B -> C -> D
  }
  
  // MARK: - Graph Properties
  
  @Test("Is connected")
  func testIsConnected() {
    let connected = Graph<Int>()
    connected.addEdge(from: 1, to: 2)
    connected.addEdge(from: 2, to: 3)
    
    #expect(connected.isConnected())
    
    let disconnected = Graph<Int>()
    disconnected.addVertex(1)
    disconnected.addVertex(2)
    
    #expect(!disconnected.isConnected())
  }
  
  @Test("Has cycle")
  func testHasCycle() {
    let cyclic = Graph<Int>(edgeType: .directed)
    cyclic.addEdge(from: 1, to: 2)
    cyclic.addEdge(from: 2, to: 3)
    cyclic.addEdge(from: 3, to: 1)
    
    #expect(cyclic.hasCycle())
    
    let acyclic = Graph<Int>(edgeType: .directed)
    acyclic.addEdge(from: 1, to: 2)
    acyclic.addEdge(from: 2, to: 3)
    
    #expect(!acyclic.hasCycle())
  }
  
  // MARK: - Topological Sort
  
  @Test("Topological sort")
  func testTopologicalSort() {
    let graph = Graph<String>(edgeType: .directed)
    
    graph.addEdge(from: "A", to: "B")
    graph.addEdge(from: "A", to: "C")
    graph.addEdge(from: "B", to: "D")
    graph.addEdge(from: "C", to: "D")
    
    let sorted = graph.topologicalSort()
    
    #expect(sorted != nil)
    #expect(sorted?.count == 4)
    
    // A must come before B, C; B, C must come before D
    if let s = sorted {
      #expect(s.firstIndex(of: "A")! < s.firstIndex(of: "B")!)
      #expect(s.firstIndex(of: "A")! < s.firstIndex(of: "C")!)
      #expect(s.firstIndex(of: "B")! < s.firstIndex(of: "D")!)
      #expect(s.firstIndex(of: "C")! < s.firstIndex(of: "D")!)
    }
  }
  
  @Test("Topological sort fails on cyclic graph")
  func testTopologicalSortCycle() {
    let graph = Graph<Int>(edgeType: .directed)
    
    graph.addEdge(from: 1, to: 2)
    graph.addEdge(from: 2, to: 3)
    graph.addEdge(from: 3, to: 1)
    
    #expect(graph.topologicalSort() == nil)
  }
  
  // MARK: - Degree
  
  @Test("Vertex degree")
  func testDegree() {
    let graph = Graph<String>()
    
    graph.addEdge(from: "A", to: "B")
    graph.addEdge(from: "A", to: "C")
    graph.addEdge(from: "A", to: "D")
    
    #expect(graph.degree(of: "A") == 3)
    #expect(graph.degree(of: "B") == 1)
  }
}
