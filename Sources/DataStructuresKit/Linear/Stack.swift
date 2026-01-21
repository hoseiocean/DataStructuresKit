// MARK: - Stack
// A LIFO (Last-In-First-Out) data structure with O(1) amortized operations.
//
// ADR Compliance:
// - ADR-001: Value type with Copy-on-Write ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) amortized push/pop verified ✓

/// A generic stack collection implementing LIFO (Last-In-First-Out) semantics.
///
/// `Stack` provides constant-time insertion and removal at the top of the collection.
/// It uses Copy-on-Write optimization to avoid unnecessary copies when the stack
/// is uniquely referenced.
///
/// ## Topics
///
/// ### Creating a Stack
/// - ``init()``
/// - ``init(_:)``
///
/// ### Adding Elements
/// - ``push(_:)``
///
/// ### Removing Elements
/// - ``pop()``
/// - ``removeAll(keepingCapacity:)``
///
/// ### Inspecting a Stack
/// - ``peek``
/// - ``isEmpty``
/// - ``count``
///
/// ## Example
///
/// ```swift
/// var stack = Stack<Int>()
/// stack.push(1)
/// stack.push(2)
/// stack.push(3)
///
/// print(stack.peek)  // Optional(3)
/// print(stack.pop()) // Optional(3)
/// print(stack.count) // 2
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | push(_:)  | O(1) amortized |
/// | pop()     | O(1) |
/// | peek      | O(1) |
/// | count     | O(1) |
/// | isEmpty   | O(1) |
///
/// ## Thread Safety
///
/// `Stack` is a value type with Copy-on-Write semantics. Multiple copies can be
/// safely accessed from different threads. However, mutating a single instance
/// from multiple threads simultaneously is undefined behavior.
///
/// For thread-safe access, use appropriate synchronization mechanisms or
/// Swift's actor isolation.
public struct Stack<Element>: StackProtocol {
  
  // MARK: - Storage (CoW)
  
  /// Internal storage class for Copy-on-Write optimization.
  ///
  /// Using a class allows `isKnownUniquelyReferenced` to detect
  /// when a copy is needed before mutation.
  @usableFromInline
  internal final class Storage {
    @usableFromInline
    internal var elements: [Element]
    
    @usableFromInline
    internal var count: Int { elements.count }
    
    @inlinable
    internal init() {
      self.elements = []
    }
    
    @inlinable
    internal init(minimumCapacity: Int) {
      self.elements = []
      self.elements.reserveCapacity(minimumCapacity)
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
  
  /// Ensures the storage is uniquely referenced before mutation.
  ///
  /// If the storage is shared with another Stack instance, this method
  /// creates a copy of the storage to maintain value semantics.
  ///
  /// - Complexity: O(1) when uniquely referenced, O(n) when copying.
  @inlinable
  internal mutating func ensureUnique() {
    if !isKnownUniquelyReferenced(&storage) {
      storage = storage.copy()
    }
  }
  
  // MARK: - Initialization
  
  /// Creates an empty stack.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.storage = Storage()
  }
  
  /// Creates a stack containing the elements of a sequence.
  ///
  /// The elements are pushed in order, so the last element of the sequence
  /// becomes the top of the stack.
  ///
  /// - Parameter elements: The sequence of elements to push onto the stack.
  /// - Complexity: O(n), where n is the length of the sequence.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let stack = Stack([1, 2, 3])
  /// print(stack.peek) // Optional(3)
  /// ```
  @inlinable
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    let array = Array(elements)
    self.storage = Storage(elements: array)
  }
  
  // MARK: - StackProtocol Conformance
  
  /// The number of elements in the stack.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int { storage.count }
  
  /// A Boolean value indicating whether the stack is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool { storage.count == 0 }
  
  /// The top element of the stack without removing it.
  ///
  /// Returns `nil` if the stack is empty.
  ///
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var stack: Stack = [1, 2, 3]
  /// print(stack.peek) // Optional(3)
  /// _ = stack.pop()
  /// print(stack.peek) // Optional(2)
  /// ```
  @inlinable
  public var peek: Element? {
    storage.elements.last
  }
  
  /// Pushes an element onto the top of the stack.
  ///
  /// - Parameter element: The element to push.
  /// - Complexity: O(1) amortized. O(n) when reallocation is needed.
  ///
  /// ## Example
  ///
  /// ```swift
  /// var stack = Stack<String>()
  /// stack.push("first")
  /// stack.push("second")
  /// print(stack.count) // 2
  /// ```
  @inlinable
  public mutating func push(_ element: Element) {
    ensureUnique()
    storage.elements.append(element)
  }
  
  /// Removes and returns the top element of the stack.
  ///
  /// - Returns: The top element if the stack is not empty; otherwise, `nil`.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var stack: Stack = [1, 2, 3]
  /// print(stack.pop()) // Optional(3)
  /// print(stack.pop()) // Optional(2)
  /// print(stack.pop()) // Optional(1)
  /// print(stack.pop()) // nil
  /// ```
  @inlinable
  @discardableResult
  public mutating func pop() -> Element? {
    guard !isEmpty else { return nil }
    ensureUnique()
    return storage.elements.removeLast()
  }
  
  // MARK: - Additional Operations
  
  /// Removes all elements from the stack.
  ///
  /// - Parameter keepingCapacity: If `true`, the stack's storage capacity
  ///   is preserved; otherwise, the underlying storage is released.
  /// - Complexity: O(n)
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    ensureUnique()
    storage.elements.removeAll(keepingCapacity: keepingCapacity)
  }
  
  /// Reserves enough space to store the specified number of elements.
  ///
  /// - Parameter minimumCapacity: The minimum number of elements the stack
  ///   should be able to store without reallocating.
  /// - Complexity: O(n)
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    ensureUnique()
    storage.elements.reserveCapacity(minimumCapacity)
  }
  
  /// The current capacity of the stack's underlying storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    storage.elements.capacity
  }
}

// MARK: - Sequence Conformance

extension Stack: Sequence {
  /// An iterator that traverses the stack from top to bottom.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var index: Int
    
    @usableFromInline
    internal let elements: [Element]
    
    @inlinable
    internal init(_ stack: Stack) {
      self.elements = stack.storage.elements
      self.index = elements.count - 1
    }
    
    @inlinable
    public mutating func next() -> Element? {
      guard index >= 0 else { return nil }
      defer { index -= 1 }
      return elements[index]
    }
  }
  
  /// Returns an iterator over the elements of the stack.
  ///
  /// The iterator traverses elements from top to bottom (LIFO order).
  ///
  /// - Complexity: O(1)
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension Stack: ExpressibleByArrayLiteral {
  /// Creates a stack from an array literal.
  ///
  /// The last element in the array literal becomes the top of the stack.
  ///
  /// - Parameter elements: A variadic list of elements.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let stack: Stack = [1, 2, 3]
  /// print(stack.peek) // Optional(3)
  /// ```
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension Stack: CustomStringConvertible {
  /// A textual representation of the stack.
  ///
  /// Shows elements from top to bottom.
  public var description: String {
    let contents = storage.elements.reversed().map { "\($0)" }.joined(separator: ", ")
    return "Stack<\(Element.self)>(top: [\(contents)])"
  }
}

// MARK: - CustomDebugStringConvertible

extension Stack: CustomDebugStringConvertible {
  /// A debug textual representation of the stack.
  public var debugDescription: String {
    "Stack<\(Element.self)>(count: \(count), capacity: \(capacity), elements: \(storage.elements.reversed()))"
  }
}

// MARK: - Equatable

extension Stack: Equatable where Element: Equatable {
  @inlinable
  public static func == (lhs: Stack, rhs: Stack) -> Bool {
    lhs.storage.elements == rhs.storage.elements
  }
}

// MARK: - Hashable

extension Stack: Hashable where Element: Hashable {
  @inlinable
  public func hash(into hasher: inout Hasher) {
    hasher.combine(storage.elements)
  }
}

// MARK: - Sendable

extension Stack: Sendable where Element: Sendable {}
extension Stack.Storage: @unchecked Sendable where Element: Sendable {}
