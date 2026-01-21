// MARK: - PriorityQueue
// A priority queue built on top of Heap for a cleaner API.
//
// ADR Compliance:
// - ADR-001: Value type (wraps Heap which has CoW) ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(log n) insert/extractTop, O(1) top verified ✓

/// A priority queue providing efficient access to the highest-priority element.
///
/// `PriorityQueue` is a convenience wrapper around `Heap` that provides
/// a more intuitive API for common priority queue operations.
///
/// ## Priority Order
///
/// By default, `PriorityQueue` is a min-priority queue where the smallest
/// element has the highest priority. Use ``maxPriorityQueue()`` for a
/// max-priority queue.
///
/// ## Example
///
/// ```swift
/// // Min-priority queue (default): smallest = highest priority
/// var tasks = PriorityQueue<Int>()
/// tasks.insert(5)
/// tasks.insert(1)
/// tasks.insert(3)
///
/// print(tasks.extractTop()) // Optional(1)
/// print(tasks.extractTop()) // Optional(3)
///
/// // Max-priority queue: largest = highest priority
/// var scores = PriorityQueue<Int>.maxPriorityQueue()
/// scores.insert(100)
/// scores.insert(250)
/// scores.insert(175)
///
/// print(scores.extractTop()) // Optional(250)
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | insert(_:) | O(log n) |
/// | extractTop() | O(log n) |
/// | top | O(1) |
/// | count | O(1) |
public struct PriorityQueue<Element>: PriorityQueueProtocol {
  
  @usableFromInline
  internal var heap: Heap<Element>
  
  // MARK: - Initialization
  
  /// Creates an empty priority queue with the given comparator.
  ///
  /// - Parameter comparator: Returns `true` if first element has higher priority.
  @inlinable
  public init(comparator: @escaping (Element, Element) -> Bool) {
    self.heap = Heap(comparator: comparator)
  }
  
  /// Creates a priority queue from a sequence.
  ///
  /// - Parameters:
  ///   - elements: The initial elements.
  ///   - comparator: Returns `true` if first element has higher priority.
  /// - Complexity: O(n)
  @inlinable
  public init<S: Sequence>(_ elements: S, comparator: @escaping (Element, Element) -> Bool) where S.Element == Element {
    self.heap = Heap(elements, comparator: comparator)
  }
  
  // MARK: - Factory Methods (Comparable Elements)
  
  /// Creates an empty min-priority queue.
  ///
  /// The smallest element has the highest priority.
  @inlinable
  public static func minPriorityQueue() -> PriorityQueue where Element: Comparable {
    PriorityQueue(comparator: <)
  }
  
  /// Creates an empty max-priority queue.
  ///
  /// The largest element has the highest priority.
  @inlinable
  public static func maxPriorityQueue() -> PriorityQueue where Element: Comparable {
    PriorityQueue(comparator: >)
  }
  
  /// Creates a min-priority queue from a sequence.
  @inlinable
  public static func minPriorityQueue<S: Sequence>(_ elements: S) -> PriorityQueue where Element: Comparable, S.Element == Element {
    PriorityQueue(elements, comparator: <)
  }
  
  /// Creates a max-priority queue from a sequence.
  @inlinable
  public static func maxPriorityQueue<S: Sequence>(_ elements: S) -> PriorityQueue where Element: Comparable, S.Element == Element {
    PriorityQueue(elements, comparator: >)
  }
  
  // MARK: - Properties
  
  /// The number of elements in the queue.
  @inlinable
  public var count: Int { heap.count }
  
  /// A Boolean value indicating whether the queue is empty.
  @inlinable
  public var isEmpty: Bool { heap.isEmpty }
  
  /// The highest-priority element without removing it.
  @inlinable
  public var top: Element? { heap.peek }
  
  // MARK: - PriorityQueueProtocol Conformance
  
  /// Inserts an element into the priority queue.
  ///
  /// - Complexity: O(log n)
  @inlinable
  public mutating func insert(_ element: Element) {
    heap.insert(element)
  }
  
  /// Removes and returns the highest-priority element.
  ///
  /// - Complexity: O(log n)
  @inlinable
  @discardableResult
  public mutating func extractTop() -> Element? {
    heap.extract()
  }
  
  // MARK: - Additional Operations
  
  /// Removes all elements from the queue.
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    heap.removeAll(keepingCapacity: keepingCapacity)
  }
  
  /// Reserves capacity for the specified number of elements.
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    heap.reserveCapacity(minimumCapacity)
  }
}

// MARK: - Default Initializers for Comparable Types

extension PriorityQueue where Element: Comparable {
  /// Creates an empty min-priority queue.
  ///
  /// Equivalent to ``minPriorityQueue()``.
  @inlinable
  public init() {
    self.heap = Heap.minHeap()
  }
  
  /// Creates a min-priority queue from a sequence.
  @inlinable
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    self.heap = Heap.minHeap(elements)
  }
}

// MARK: - Sequence Conformance

extension PriorityQueue: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var queue: PriorityQueue
    
    @inlinable
    internal init(_ queue: PriorityQueue) {
      self.queue = queue
    }
    
    @inlinable
    public mutating func next() -> Element? {
      queue.extractTop()
    }
  }
  
  /// Returns an iterator that extracts elements in priority order.
  ///
  /// - Complexity: O(1) to create, O(n log n) to fully iterate.
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension PriorityQueue: ExpressibleByArrayLiteral where Element: Comparable {
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension PriorityQueue: CustomStringConvertible {
  public var description: String {
    "PriorityQueue<\(Element.self)>(count: \(count), top: \(top.map { "\($0)" } ?? "nil"))"
  }
}

// MARK: - Sendable

extension PriorityQueue: Sendable where Element: Sendable {}
