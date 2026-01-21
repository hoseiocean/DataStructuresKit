// MARK: - Queue
// A FIFO (First-In-First-Out) data structure with O(1) operations.
//
// Implementation: Circular buffer (ring buffer) for O(1) enqueue and dequeue.
//
// ADR Compliance:
// - ADR-001: Value type with Copy-on-Write ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) amortized enqueue, O(1) dequeue verified ✓

/// A generic queue collection implementing FIFO (First-In-First-Out) semantics.
///
/// `Queue` provides constant-time insertion at the back and removal at the front
/// using a circular buffer implementation. It uses Copy-on-Write optimization
/// to avoid unnecessary copies when the queue is uniquely referenced.
///
/// ## Topics
///
/// ### Creating a Queue
/// - ``init()``
/// - ``init(minimumCapacity:)``
/// - ``init(_:)``
///
/// ### Adding Elements
/// - ``enqueue(_:)``
///
/// ### Removing Elements
/// - ``dequeue()``
/// - ``removeAll(keepingCapacity:)``
///
/// ### Inspecting a Queue
/// - ``front``
/// - ``back``
/// - ``isEmpty``
/// - ``count``
///
/// ## Example
///
/// ```swift
/// var queue = Queue<Int>()
/// queue.enqueue(1)
/// queue.enqueue(2)
/// queue.enqueue(3)
///
/// print(queue.front)   // Optional(1)
/// print(queue.dequeue()) // Optional(1)
/// print(queue.count)    // 2
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | enqueue(_:) | O(1) amortized |
/// | dequeue()   | O(1) |
/// | front       | O(1) |
/// | back        | O(1) |
/// | count       | O(1) |
///
/// ## Implementation Details
///
/// Uses a circular buffer (ring buffer) to achieve O(1) dequeue operations.
/// The buffer grows when full and shrinks when utilization drops below 25%.
public struct Queue<Element>: QueueProtocol {
  
  // MARK: - Storage (CoW with Circular Buffer)
  
  @usableFromInline
  internal final class Storage {
    @usableFromInline
    internal var buffer: [Element?]
    
    @usableFromInline
    internal var head: Int  // Index of front element
    
    @usableFromInline
    internal var tail: Int  // Index where next element will be inserted
    
    @usableFromInline
    internal var count: Int
    
    @inlinable
    internal var capacity: Int { buffer.count }
    
    @inlinable
    internal init(minimumCapacity: Int = 16) {
      let capacity = Swift.max(minimumCapacity, 1)
      self.buffer = [Element?](repeating: nil, count: capacity)
      self.head = 0
      self.tail = 0
      self.count = 0
    }
    
    @inlinable
    internal func copy() -> Storage {
      let newStorage = Storage(minimumCapacity: buffer.count)
      newStorage.buffer = buffer
      newStorage.head = head
      newStorage.tail = tail
      newStorage.count = count
      return newStorage
    }
    
    /// Returns the actual index in the circular buffer.
    @inlinable
    internal func bufferIndex(_ index: Int) -> Int {
      (head + index) % capacity
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
  
  /// Creates an empty queue with default capacity.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.storage = Storage()
  }
  
  /// Creates an empty queue with the specified minimum capacity.
  ///
  /// - Parameter minimumCapacity: The minimum number of elements the queue
  ///   should be able to store without reallocating.
  /// - Complexity: O(1)
  @inlinable
  public init(minimumCapacity: Int) {
    self.storage = Storage(minimumCapacity: minimumCapacity)
  }
  
  /// Creates a queue containing the elements of a sequence.
  ///
  /// The first element of the sequence becomes the front of the queue.
  ///
  /// - Parameter elements: The sequence of elements to enqueue.
  /// - Complexity: O(n), where n is the length of the sequence.
  @inlinable
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    let array = Array(elements)
    self.storage = Storage(minimumCapacity: Swift.max(array.count, 16))
    for element in array {
      storage.buffer[storage.tail] = element
      storage.tail = (storage.tail + 1) % storage.capacity
      storage.count += 1
    }
  }
  
  // MARK: - QueueProtocol Conformance
  
  /// The number of elements in the queue.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int { storage.count }
  
  /// A Boolean value indicating whether the queue is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool { storage.count == 0 }
  
  /// The front element of the queue without removing it.
  ///
  /// Returns `nil` if the queue is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var front: Element? {
    guard !isEmpty else { return nil }
    return storage.buffer[storage.head]
  }
  
  /// The back element of the queue without removing it.
  ///
  /// Returns `nil` if the queue is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var back: Element? {
    guard !isEmpty else { return nil }
    let index = (storage.tail - 1 + storage.capacity) % storage.capacity
    return storage.buffer[index]
  }
  
  /// Adds an element to the back of the queue.
  ///
  /// If the queue's buffer is full, it will be resized to accommodate
  /// the new element.
  ///
  /// - Parameter element: The element to enqueue.
  /// - Complexity: O(1) amortized. O(n) when resizing is needed.
  @inlinable
  public mutating func enqueue(_ element: Element) {
    ensureUnique()
    
    // Resize if full
    if storage.count == storage.capacity {
      resize(to: storage.capacity * 2)
    }
    
    storage.buffer[storage.tail] = element
    storage.tail = (storage.tail + 1) % storage.capacity
    storage.count += 1
  }
  
  /// Removes and returns the front element of the queue.
  ///
  /// - Returns: The front element if the queue is not empty; otherwise, `nil`.
  /// - Complexity: O(1) amortized. May trigger shrinking if utilization is low.
  @inlinable
  @discardableResult
  public mutating func dequeue() -> Element? {
    guard !isEmpty else { return nil }
    ensureUnique()
    
    let element = storage.buffer[storage.head]
    storage.buffer[storage.head] = nil  // Release reference
    storage.head = (storage.head + 1) % storage.capacity
    storage.count -= 1
    
    // Shrink if utilization drops below 25% (minimum capacity 16)
    if storage.count > 0 && storage.count <= storage.capacity / 4 && storage.capacity > 16 {
      resize(to: storage.capacity / 2)
    }
    
    return element
  }
  
  // MARK: - Private Helpers
  
  /// Resizes the circular buffer to the new capacity.
  ///
  /// Elements are copied to a contiguous block starting at index 0.
  @inlinable
  internal mutating func resize(to newCapacity: Int) {
    var newBuffer = [Element?](repeating: nil, count: newCapacity)
    
    // Copy elements to new buffer starting at index 0
    for i in 0..<storage.count {
      newBuffer[i] = storage.buffer[(storage.head + i) % storage.capacity]
    }
    
    storage.buffer = newBuffer
    storage.head = 0
    storage.tail = storage.count
  }
  
  // MARK: - Additional Operations
  
  /// Removes all elements from the queue.
  ///
  /// - Parameter keepingCapacity: If `true`, the queue's storage capacity
  ///   is preserved; otherwise, the underlying storage is released.
  /// - Complexity: O(n)
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    ensureUnique()
    if keepingCapacity {
      for i in 0..<storage.count {
        storage.buffer[(storage.head + i) % storage.capacity] = nil
      }
      storage.head = 0
      storage.tail = 0
      storage.count = 0
    } else {
      storage = Storage()
    }
  }
  
  /// The current capacity of the queue's underlying storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    storage.capacity
  }
  
  /// Reserves enough space to store the specified number of elements.
  ///
  /// - Parameter minimumCapacity: The minimum number of elements the queue
  ///   should be able to store without reallocating.
  /// - Complexity: O(n)
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    if minimumCapacity > storage.capacity {
      ensureUnique()
      resize(to: minimumCapacity)
    }
  }
}

// MARK: - Sequence Conformance

extension Queue: Sequence {
  /// An iterator that traverses the queue from front to back.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var currentIndex: Int
    
    @usableFromInline
    internal let queue: Queue
    
    @inlinable
    internal init(_ queue: Queue) {
      self.queue = queue
      self.currentIndex = 0
    }
    
    @inlinable
    public mutating func next() -> Element? {
      guard currentIndex < queue.count else { return nil }
      let index = queue.storage.bufferIndex(currentIndex)
      currentIndex += 1
      return queue.storage.buffer[index]
    }
  }
  
  /// Returns an iterator over the elements of the queue.
  ///
  /// The iterator traverses elements from front to back (FIFO order).
  ///
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension Queue: ExpressibleByArrayLiteral {
  /// Creates a queue from an array literal.
  ///
  /// The first element in the array literal becomes the front of the queue.
  ///
  /// - Parameter elements: A variadic list of elements.
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension Queue: CustomStringConvertible {
  public var description: String {
    let contents = map { "\($0)" }.joined(separator: ", ")
    return "Queue<\(Element.self)>(front: [\(contents)])"
  }
}

// MARK: - CustomDebugStringConvertible

extension Queue: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Queue<\(Element.self)>(count: \(count), capacity: \(capacity), head: \(storage.head), tail: \(storage.tail))"
  }
}

// MARK: - Equatable

extension Queue: Equatable where Element: Equatable {
  @inlinable
  public static func == (lhs: Queue, rhs: Queue) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (a, b) in zip(lhs, rhs) {
      if a != b { return false }
    }
    return true
  }
}

// MARK: - Hashable

extension Queue: Hashable where Element: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count)
    for element in self {
      hasher.combine(element)
    }
  }
}

// MARK: - Sendable

extension Queue: Sendable where Element: Sendable {}
extension Queue.Storage: @unchecked Sendable where Element: Sendable {}
