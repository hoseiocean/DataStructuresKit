// MARK: - DataStructuresKit Protocols
// Shared protocols defining common behavior across data structures

/// A type that can report whether it contains any elements.
///
/// Types conforming to `EmptyCheckable` provide a constant-time check
/// for emptiness, which is more efficient than checking `count == 0`
/// for some collection types.
public protocol EmptyCheckable {
  /// A Boolean value indicating whether the collection is empty.
  ///
  /// - Complexity: O(1)
  var isEmpty: Bool { get }
}

/// A type that can report its element count.
///
/// Types conforming to `Countable` provide the number of elements
/// they contain.
public protocol Countable: EmptyCheckable {
  /// The number of elements in the collection.
  ///
  /// - Complexity: O(1)
  var count: Int { get }
}

// Default implementation: isEmpty based on count
extension Countable {
  @inlinable
  public var isEmpty: Bool { count == 0 }
}

// MARK: - Stack Protocol

/// A type that provides LIFO (Last-In-First-Out) access to its elements.
///
/// Stack operations:
/// - `push(_:)`: Add element to top - O(1) amortized
/// - `pop()`: Remove and return top element - O(1)
/// - `peek`: Access top element without removal - O(1)
public protocol StackProtocol<Element>: Countable {
  associatedtype Element
  
  /// Adds an element to the top of the stack.
  ///
  /// - Parameter element: The element to push onto the stack.
  /// - Complexity: O(1) amortized
  mutating func push(_ element: Element)
  
  /// Removes and returns the top element of the stack.
  ///
  /// - Returns: The top element, or `nil` if the stack is empty.
  /// - Complexity: O(1)
  @discardableResult
  mutating func pop() -> Element?
  
  /// The top element of the stack without removing it.
  ///
  /// - Complexity: O(1)
  var peek: Element? { get }
}

// MARK: - Queue Protocol

/// A type that provides FIFO (First-In-First-Out) access to its elements.
///
/// Queue operations:
/// - `enqueue(_:)`: Add element to back - O(1) amortized
/// - `dequeue()`: Remove and return front element - O(1)
/// - `front`: Access front element without removal - O(1)
public protocol QueueProtocol<Element>: Countable {
  associatedtype Element
  
  /// Adds an element to the back of the queue.
  ///
  /// - Parameter element: The element to enqueue.
  /// - Complexity: O(1) amortized
  mutating func enqueue(_ element: Element)
  
  /// Removes and returns the front element of the queue.
  ///
  /// - Returns: The front element, or `nil` if the queue is empty.
  /// - Complexity: O(1)
  @discardableResult
  mutating func dequeue() -> Element?
  
  /// The front element of the queue without removing it.
  ///
  /// - Complexity: O(1)
  var front: Element? { get }
}

// MARK: - Deque Protocol

/// A type that provides double-ended access to its elements.
///
/// Deque (double-ended queue) supports efficient insertion and removal
/// at both ends.
public protocol DequeProtocol<Element>: Countable {
  associatedtype Element
  
  /// Adds an element to the front.
  ///
  /// - Complexity: O(1) amortized
  mutating func pushFront(_ element: Element)
  
  /// Adds an element to the back.
  ///
  /// - Complexity: O(1) amortized
  mutating func pushBack(_ element: Element)
  
  /// Removes and returns the front element.
  ///
  /// - Complexity: O(1)
  @discardableResult
  mutating func popFront() -> Element?
  
  /// Removes and returns the back element.
  ///
  /// - Complexity: O(1)
  @discardableResult
  mutating func popBack() -> Element?
  
  /// The front element without removing it.
  ///
  /// - Complexity: O(1)
  var front: Element? { get }
  
  /// The back element without removing it.
  ///
  /// - Complexity: O(1)
  var back: Element? { get }
}

// MARK: - Priority Queue Protocol

/// A type that provides access to its minimum or maximum element.
///
/// Priority queues maintain a heap property ensuring the highest
/// (or lowest) priority element is always accessible in O(1) time.
public protocol PriorityQueueProtocol<Element>: Countable {
  associatedtype Element
  
  /// Inserts an element into the priority queue.
  ///
  /// - Complexity: O(log n)
  mutating func insert(_ element: Element)
  
  /// Removes and returns the highest priority element.
  ///
  /// - Complexity: O(log n)
  @discardableResult
  mutating func extractTop() -> Element?
  
  /// The highest priority element without removing it.
  ///
  /// - Complexity: O(1)
  var top: Element? { get }
}

// MARK: - Tree Protocol

/// A type representing a tree node with children.
public protocol TreeNodeProtocol<Value>: AnyObject {
  associatedtype Value
  
  var value: Value { get set }
  var children: [Self] { get }
  var isLeaf: Bool { get }
}

extension TreeNodeProtocol {
  @inlinable
  public var isLeaf: Bool { children.isEmpty }
}

// MARK: - Graph Protocol

/// A type representing a graph with vertices and edges.
public protocol GraphProtocol<Vertex> {
  associatedtype Vertex: Hashable
  associatedtype Edge
  
  /// All vertices in the graph.
  var vertices: [Vertex] { get }
  
  /// Adds a vertex to the graph.
  mutating func addVertex(_ vertex: Vertex)
  
  /// Adds an edge between two vertices.
  mutating func addEdge(from source: Vertex, to destination: Vertex)
  
  /// Returns all edges originating from a vertex.
  func edges(from vertex: Vertex) -> [Edge]
  
  /// Returns all neighbors of a vertex.
  func neighbors(of vertex: Vertex) -> [Vertex]
}
