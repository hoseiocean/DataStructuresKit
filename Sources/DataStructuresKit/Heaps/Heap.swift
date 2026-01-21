// MARK: - Heap
// A binary heap implementation with O(log n) insert and extract operations.
//
// ADR Compliance:
// - ADR-001: Value type with Copy-on-Write ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(log n) insert/extract, O(1) peek verified ✓

/// A binary heap data structure supporting efficient priority queue operations.
///
/// `Heap` maintains the heap property using a complete binary tree stored in an array.
/// It supports both min-heap and max-heap configurations through a custom comparator.
///
/// ## Example
///
/// ```swift
/// var minHeap = Heap<Int>.minHeap()
/// minHeap.insert(5)
/// minHeap.insert(3)
/// minHeap.insert(7)
/// minHeap.insert(1)
///
/// print(minHeap.extract()) // Optional(1)
/// print(minHeap.extract()) // Optional(3)
/// print(minHeap.peek)      // Optional(5)
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | insert(_:) | O(log n) |
/// | extract()  | O(log n) |
/// | peek       | O(1) |
/// | count      | O(1) |
/// | build heap | O(n) |
public struct Heap<Element> {
  
  /// The comparison function determining heap order.
  public let comparator: (Element, Element) -> Bool
  
  // MARK: - Storage (CoW)
  
  @usableFromInline
  internal final class Storage {
    @usableFromInline
    internal var elements: [Element]
    
    @inlinable
    internal var count: Int { elements.count }
    
    @inlinable
    internal init() {
      self.elements = []
    }
    
    @inlinable
    internal init(elements: [Element]) {
      self.elements = elements
    }
    
    @inlinable
    internal func copy() -> Storage {
      Storage(elements: elements)
    }
  }
  
  @usableFromInline
  internal var storage: Storage
  
  // MARK: - Copy-on-Write
  
  @inlinable
  internal mutating func ensureUnique() {
    if !isKnownUniquelyReferenced(&storage) {
      storage = storage.copy()
    }
  }
  
  // MARK: - Initialization
  
  /// Creates an empty heap with the given comparator.
  ///
  /// - Parameter comparator: Returns `true` if first element has higher priority.
  public init(comparator: @escaping (Element, Element) -> Bool) {
    self.comparator = comparator
    self.storage = Storage()
  }
  
  /// Creates a heap from a sequence using Floyd's O(n) algorithm.
  public init<S: Sequence>(_ elements: S, comparator: @escaping (Element, Element) -> Bool) where S.Element == Element {
    self.comparator = comparator
    self.storage = Storage(elements: Array(elements))
    buildHeap()
  }
  
  // MARK: - Factory Methods
  
  /// Creates an empty min-heap (smallest element has highest priority).
  @inlinable
  public static func minHeap() -> Heap where Element: Comparable {
    Heap(comparator: <)
  }
  
  /// Creates an empty max-heap (largest element has highest priority).
  @inlinable
  public static func maxHeap() -> Heap where Element: Comparable {
    Heap(comparator: >)
  }
  
  /// Creates a min-heap from a sequence.
  @inlinable
  public static func minHeap<S: Sequence>(_ elements: S) -> Heap where Element: Comparable, S.Element == Element {
    Heap(elements, comparator: <)
  }
  
  /// Creates a max-heap from a sequence.
  @inlinable
  public static func maxHeap<S: Sequence>(_ elements: S) -> Heap where Element: Comparable, S.Element == Element {
    Heap(elements, comparator: >)
  }
  
  // MARK: - Properties
  
  /// The number of elements in the heap.
  @inlinable
  public var count: Int { storage.count }
  
  /// A Boolean value indicating whether the heap is empty.
  @inlinable
  public var isEmpty: Bool { storage.count == 0 }
  
  /// The highest-priority element without removing it.
  @inlinable
  public var peek: Element? { storage.elements.first }
  
  /// The current capacity of the underlying storage.
  @inlinable
  public var capacity: Int { storage.elements.capacity }
  
  // MARK: - Operations
  
  /// Inserts an element into the heap.
  ///
  /// - Complexity: O(log n)
  @inlinable
  public mutating func insert(_ element: Element) {
    ensureUnique()
    storage.elements.append(element)
    siftUp(from: storage.count - 1)
  }
  
  /// Removes and returns the highest-priority element.
  ///
  /// - Complexity: O(log n)
  @inlinable
  @discardableResult
  public mutating func extract() -> Element? {
    guard !isEmpty else { return nil }
    ensureUnique()
    
    if storage.count == 1 {
      return storage.elements.removeLast()
    }
    
    let root = storage.elements[0]
    storage.elements[0] = storage.elements.removeLast()
    siftDown(from: 0)
    
    return root
  }
  
  /// Removes all elements from the heap.
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    ensureUnique()
    storage.elements.removeAll(keepingCapacity: keepingCapacity)
  }
  
  /// Reserves capacity for the specified number of elements.
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    ensureUnique()
    storage.elements.reserveCapacity(minimumCapacity)
  }
  
  // MARK: - Private Heap Operations
  
  /// Builds a valid heap from an unordered array using Floyd's algorithm.
  /// - Complexity: O(n)
  @usableFromInline
  internal mutating func buildHeap() {
    guard storage.count > 1 else { return }
    for i in stride(from: (storage.count - 2) / 2, through: 0, by: -1) {
      siftDown(from: i)
    }
  }
  
  /// Restores heap property by moving an element up.
  /// - Complexity: O(log n)
  @usableFromInline
  internal mutating func siftUp(from index: Int) {
    var childIndex = index
    let element = storage.elements[childIndex]
    
    while childIndex > 0 {
      let parentIndex = (childIndex - 1) / 2
      let parent = storage.elements[parentIndex]
      
      if comparator(element, parent) {
        storage.elements[childIndex] = parent
        childIndex = parentIndex
      } else {
        break
      }
    }
    
    storage.elements[childIndex] = element
  }
  
  /// Restores heap property by moving an element down.
  /// - Complexity: O(log n)
  @usableFromInline
  internal mutating func siftDown(from index: Int) {
    let count = storage.count
    var parentIndex = index
    let element = storage.elements[parentIndex]
    
    while true {
      let leftChildIndex = 2 * parentIndex + 1
      let rightChildIndex = leftChildIndex + 1
      var targetIndex = parentIndex
      
      if leftChildIndex < count && comparator(storage.elements[leftChildIndex], storage.elements[targetIndex]) {
        targetIndex = leftChildIndex
      }
      
      if rightChildIndex < count && comparator(storage.elements[rightChildIndex], storage.elements[targetIndex]) {
        targetIndex = rightChildIndex
      }
      
      if targetIndex == parentIndex {
        break
      }
      
      storage.elements[parentIndex] = storage.elements[targetIndex]
      parentIndex = targetIndex
    }
    
    storage.elements[parentIndex] = element
  }
}

// MARK: - Sequence Conformance

extension Heap: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var heap: Heap
    
    @inlinable
    internal init(_ heap: Heap) {
      self.heap = heap
    }
    
    @inlinable
    public mutating func next() -> Element? {
      heap.extract()
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - CustomStringConvertible

extension Heap: CustomStringConvertible {
  public var description: String {
    "Heap<\(Element.self)>(count: \(count), root: \(peek.map { "\($0)" } ?? "nil"))"
  }
}

// MARK: - Countable

extension Heap: Countable {}

// MARK: - Sendable

extension Heap: Sendable where Element: Sendable {}
extension Heap.Storage: @unchecked Sendable where Element: Sendable {}
