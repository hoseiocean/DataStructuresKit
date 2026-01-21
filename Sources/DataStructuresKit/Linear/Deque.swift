// MARK: - Deque
// A double-ended queue with O(1) operations at both ends.
//
// Implementation: Circular buffer with growth/shrink at both ends.
//
// ADR Compliance:
// - ADR-001: Value type with Copy-on-Write ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) amortized push/pop at both ends verified ✓

/// A double-ended queue (deque) providing efficient insertion and removal at both ends.
///
/// `Deque` combines the capabilities of both `Stack` and `Queue`, allowing
/// constant-time insertion and removal at both the front and back. It uses
/// a circular buffer implementation with Copy-on-Write optimization.
///
/// ## Topics
///
/// ### Creating a Deque
/// - ``init()``
/// - ``init(minimumCapacity:)``
/// - ``init(_:)``
///
/// ### Adding Elements
/// - ``pushFront(_:)``
/// - ``pushBack(_:)``
/// - ``append(_:)``
/// - ``prepend(_:)``
///
/// ### Removing Elements
/// - ``popFront()``
/// - ``popBack()``
/// - ``removeAll(keepingCapacity:)``
///
/// ### Inspecting a Deque
/// - ``front``
/// - ``back``
/// - ``isEmpty``
/// - ``count``
///
/// ## Example
///
/// ```swift
/// var deque = Deque<Int>()
/// deque.pushBack(2)
/// deque.pushFront(1)
/// deque.pushBack(3)
/// // deque is now [1, 2, 3]
///
/// print(deque.front)    // Optional(1)
/// print(deque.back)     // Optional(3)
/// print(deque.popFront()) // Optional(1)
/// print(deque.popBack())  // Optional(3)
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | pushFront(_:) | O(1) amortized |
/// | pushBack(_:)  | O(1) amortized |
/// | popFront()    | O(1) |
/// | popBack()     | O(1) |
/// | front/back    | O(1) |
/// | subscript     | O(1) |
public struct Deque<Element>: DequeProtocol {
  
  // MARK: - Storage (CoW with Circular Buffer)
  
  @usableFromInline
  internal final class Storage {
    @usableFromInline
    internal var buffer: [Element?]
    
    @usableFromInline
    internal var head: Int  // Index of front element
    
    @usableFromInline
    internal var count: Int
    
    @inlinable
    internal var capacity: Int { buffer.count }
    
    /// Computes tail index (one past the last element).
    @inlinable
    internal var tail: Int {
      (head + count) % capacity
    }
    
    @inlinable
    internal init(minimumCapacity: Int = 16) {
      let capacity = Swift.max(minimumCapacity, 1)
      self.buffer = [Element?](repeating: nil, count: capacity)
      self.head = 0
      self.count = 0
    }
    
    @inlinable
    internal func copy() -> Storage {
      let newStorage = Storage(minimumCapacity: buffer.count)
      newStorage.buffer = buffer
      newStorage.head = head
      newStorage.count = count
      return newStorage
    }
    
    /// Converts a logical index (0 = front) to buffer index.
    @inlinable
    internal func bufferIndex(_ logicalIndex: Int) -> Int {
      (head + logicalIndex) % capacity
    }
    
    /// Wraps an index to valid buffer range, handling negative values.
    @inlinable
    internal func wrapIndex(_ index: Int) -> Int {
      ((index % capacity) + capacity) % capacity
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
  
  /// Creates an empty deque with default capacity.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.storage = Storage()
  }
  
  /// Creates an empty deque with the specified minimum capacity.
  ///
  /// - Parameter minimumCapacity: The minimum number of elements the deque
  ///   should be able to store without reallocating.
  /// - Complexity: O(1)
  @inlinable
  public init(minimumCapacity: Int) {
    self.storage = Storage(minimumCapacity: minimumCapacity)
  }
  
  /// Creates a deque containing the elements of a sequence.
  ///
  /// - Parameter elements: The sequence of elements to add.
  /// - Complexity: O(n), where n is the length of the sequence.
  @inlinable
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    let array = Array(elements)
    self.storage = Storage(minimumCapacity: Swift.max(array.count, 16))
    for (index, element) in array.enumerated() {
      storage.buffer[index] = element
    }
    storage.count = array.count
  }
  
  // MARK: - DequeProtocol Conformance
  
  /// The number of elements in the deque.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int { storage.count }
  
  /// A Boolean value indicating whether the deque is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool { storage.count == 0 }
  
  /// The first element of the deque.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var front: Element? {
    guard !isEmpty else { return nil }
    return storage.buffer[storage.head]
  }
  
  /// The last element of the deque.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var back: Element? {
    guard !isEmpty else { return nil }
    let index = storage.wrapIndex(storage.head + storage.count - 1)
    return storage.buffer[index]
  }
  
  /// Adds an element to the front of the deque.
  ///
  /// - Parameter element: The element to add.
  /// - Complexity: O(1) amortized.
  @inlinable
  public mutating func pushFront(_ element: Element) {
    ensureUnique()
    
    if storage.count == storage.capacity {
      resize(to: storage.capacity * 2)
    }
    
    storage.head = storage.wrapIndex(storage.head - 1)
    storage.buffer[storage.head] = element
    storage.count += 1
  }
  
  /// Adds an element to the back of the deque.
  ///
  /// - Parameter element: The element to add.
  /// - Complexity: O(1) amortized.
  @inlinable
  public mutating func pushBack(_ element: Element) {
    ensureUnique()
    
    if storage.count == storage.capacity {
      resize(to: storage.capacity * 2)
    }
    
    storage.buffer[storage.tail] = element
    storage.count += 1
  }
  
  /// Removes and returns the first element.
  ///
  /// - Returns: The first element, or `nil` if the deque is empty.
  /// - Complexity: O(1) amortized.
  @inlinable
  @discardableResult
  public mutating func popFront() -> Element? {
    guard !isEmpty else { return nil }
    ensureUnique()
    
    let element = storage.buffer[storage.head]
    storage.buffer[storage.head] = nil
    storage.head = (storage.head + 1) % storage.capacity
    storage.count -= 1
    
    shrinkIfNeeded()
    return element
  }
  
  /// Removes and returns the last element.
  ///
  /// - Returns: The last element, or `nil` if the deque is empty.
  /// - Complexity: O(1) amortized.
  @inlinable
  @discardableResult
  public mutating func popBack() -> Element? {
    guard !isEmpty else { return nil }
    ensureUnique()
    
    let index = storage.wrapIndex(storage.head + storage.count - 1)
    let element = storage.buffer[index]
    storage.buffer[index] = nil
    storage.count -= 1
    
    shrinkIfNeeded()
    return element
  }
  
  // MARK: - Convenience Aliases
  
  /// Adds an element to the back of the deque.
  ///
  /// This is an alias for ``pushBack(_:)``.
  @inlinable
  public mutating func append(_ element: Element) {
    pushBack(element)
  }
  
  /// Adds an element to the front of the deque.
  ///
  /// This is an alias for ``pushFront(_:)``.
  @inlinable
  public mutating func prepend(_ element: Element) {
    pushFront(element)
  }
  
  /// Removes and returns the first element.
  ///
  /// This is an alias for ``popFront()``.
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element? {
    popFront()
  }
  
  /// Removes and returns the last element.
  ///
  /// This is an alias for ``popBack()``.
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element? {
    popBack()
  }
  
  // MARK: - Random Access
  
  /// Accesses the element at the specified position.
  ///
  /// - Parameter index: The position of the element to access (0-indexed from front).
  /// - Complexity: O(1)
  /// - Precondition: `index` must be in the range `0..<count`.
  @inlinable
  public subscript(index: Int) -> Element {
    get {
      precondition(index >= 0 && index < count, "Index out of bounds")
      return storage.buffer[storage.bufferIndex(index)]!
    }
    set {
      precondition(index >= 0 && index < count, "Index out of bounds")
      ensureUnique()
      storage.buffer[storage.bufferIndex(index)] = newValue
    }
  }
  
  // MARK: - Private Helpers
  
  @inlinable
  internal mutating func resize(to newCapacity: Int) {
    var newBuffer = [Element?](repeating: nil, count: newCapacity)
    
    for i in 0..<storage.count {
      newBuffer[i] = storage.buffer[storage.bufferIndex(i)]
    }
    
    storage.buffer = newBuffer
    storage.head = 0
  }
  
  @inlinable
  internal mutating func shrinkIfNeeded() {
    // Shrink if utilization drops below 25% (minimum capacity 16)
    if storage.count > 0 && storage.count <= storage.capacity / 4 && storage.capacity > 16 {
      resize(to: storage.capacity / 2)
    }
  }
  
  // MARK: - Additional Operations
  
  /// Removes all elements from the deque.
  ///
  /// - Parameter keepingCapacity: If `true`, the storage capacity is preserved.
  /// - Complexity: O(n)
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    ensureUnique()
    if keepingCapacity {
      for i in 0..<storage.count {
        storage.buffer[storage.bufferIndex(i)] = nil
      }
      storage.head = 0
      storage.count = 0
    } else {
      storage = Storage()
    }
  }
  
  /// The current capacity of the deque's underlying storage.
  @inlinable
  public var capacity: Int { storage.capacity }
  
  /// Reserves enough space for the specified number of elements.
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    if minimumCapacity > storage.capacity {
      ensureUnique()
      resize(to: minimumCapacity)
    }
  }
}

// MARK: - Sequence Conformance

extension Deque: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var currentIndex: Int
    
    @usableFromInline
    internal let deque: Deque
    
    @inlinable
    internal init(_ deque: Deque) {
      self.deque = deque
      self.currentIndex = 0
    }
    
    @inlinable
    public mutating func next() -> Element? {
      guard currentIndex < deque.count else { return nil }
      defer { currentIndex += 1 }
      return deque[currentIndex]
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - RandomAccessCollection Conformance

extension Deque: RandomAccessCollection {
  public typealias Index = Int
  
  @inlinable
  public var startIndex: Int { 0 }
  
  @inlinable
  public var endIndex: Int { count }
  
  @inlinable
  public func index(after i: Int) -> Int { i + 1 }
  
  @inlinable
  public func index(before i: Int) -> Int { i - 1 }
}

// MARK: - ExpressibleByArrayLiteral

extension Deque: ExpressibleByArrayLiteral {
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension Deque: CustomStringConvertible {
  public var description: String {
    let contents = map { "\($0)" }.joined(separator: ", ")
    return "Deque<\(Element.self)>([\(contents)])"
  }
}

// MARK: - CustomDebugStringConvertible

extension Deque: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Deque<\(Element.self)>(count: \(count), capacity: \(capacity), head: \(storage.head))"
  }
}

// MARK: - Equatable

extension Deque: Equatable where Element: Equatable {
  @inlinable
  public static func == (lhs: Deque, rhs: Deque) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in 0..<lhs.count {
      if lhs[i] != rhs[i] { return false }
    }
    return true
  }
}

// MARK: - Hashable

extension Deque: Hashable where Element: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count)
    for element in self {
      hasher.combine(element)
    }
  }
}

// MARK: - Sendable

extension Deque: Sendable where Element: Sendable {}
extension Deque.Storage: @unchecked Sendable where Element: Sendable {}
