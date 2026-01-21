// MARK: - LinkedList
// A doubly-linked list with O(1) insertions and deletions.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - CoW too complex for node-based structure ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) prepend/append/remove(node:) verified ✓

/// A doubly-linked list providing efficient insertion and removal at any position.
///
/// `LinkedList` stores elements in nodes that reference their neighbors, enabling
/// constant-time insertion and deletion when you have a reference to the node.
/// Unlike arrays, linked lists don't support efficient random access.
///
/// ## When to Use LinkedList
///
/// - Frequent insertions/deletions at arbitrary positions
/// - Need to maintain insertion order with O(1) modification
/// - Don't need random access by index
///
/// ## When to Use Array Instead
///
/// - Need random access by index
/// - Cache locality is important
/// - Memory overhead of node pointers is a concern
///
/// ## Example
///
/// ```swift
/// let list = LinkedList<String>()
/// list.append("B")
/// let nodeA = list.prepend("A")
/// list.append("C")
/// // list is now A <-> B <-> C
///
/// list.insert("A.5", after: nodeA)
/// // list is now A <-> A.5 <-> B <-> C
///
/// list.remove(nodeA)
/// // list is now A.5 <-> B <-> C
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | prepend(_:) | O(1) |
/// | append(_:)  | O(1) |
/// | insert(_:after:) | O(1) |
/// | insert(_:before:) | O(1) |
/// | remove(_:) | O(1) |
/// | first/last | O(1) |
/// | subscript[index] | O(n) |
/// | contains(_:) | O(n) |
///
/// ## Thread Safety
///
/// `LinkedList` is a reference type and is NOT thread-safe. Concurrent access
/// from multiple threads requires external synchronization.
public final class LinkedList<Element> {
  
  // MARK: - Node
  
  /// A node in the linked list containing a value and references to neighbors.
  ///
  /// Nodes are created and managed by the `LinkedList`. You can obtain
  /// references to nodes through methods like ``prepend(_:)`` or ``node(at:)``.
  public final class Node {
    /// The value stored in this node.
    public var value: Element
    
    /// The previous node in the list, or `nil` if this is the head.
    public internal(set) weak var previous: Node?
    
    /// The next node in the list, or `nil` if this is the tail.
    public internal(set) var next: Node?
    
    /// Creates a node with the given value.
    @usableFromInline
    internal init(value: Element) {
      self.value = value
    }
    
    /// A Boolean value indicating whether this node is detached from any list.
    @inlinable
    public var isDetached: Bool {
      previous == nil && next == nil
    }
  }
  
  // MARK: - Properties
  
  /// The first node in the list.
  public private(set) var head: Node?
  
  /// The last node in the list.
  public private(set) var tail: Node?
  
  /// The number of elements in the list.
  public private(set) var count: Int = 0
  
  /// A Boolean value indicating whether the list is empty.
  @inlinable
  public var isEmpty: Bool { head == nil }
  
  /// The first element in the list.
  @inlinable
  public var first: Element? { head?.value }
  
  /// The last element in the list.
  @inlinable
  public var last: Element? { tail?.value }
  
  // MARK: - Initialization
  
  /// Creates an empty linked list.
  public init() {}
  
  /// Creates a linked list containing the elements of a sequence.
  ///
  /// - Parameter elements: The sequence of elements to add.
  /// - Complexity: O(n)
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    for element in elements {
      append(element)
    }
  }
  
  deinit {
    // Break retain cycles by clearing forward references
    var current = head
    while let node = current {
      let next = node.next
      node.next = nil
      node.previous = nil
      current = next
    }
  }
  
  // MARK: - Adding Elements
  
  /// Adds an element to the beginning of the list.
  ///
  /// - Parameter value: The value to prepend.
  /// - Returns: The newly created node.
  /// - Complexity: O(1)
  @discardableResult
  public func prepend(_ value: Element) -> Node {
    let node = Node(value: value)
    
    if let headNode = head {
      node.next = headNode
      headNode.previous = node
      head = node
    } else {
      head = node
      tail = node
    }
    
    count += 1
    return node
  }
  
  /// Adds an element to the end of the list.
  ///
  /// - Parameter value: The value to append.
  /// - Returns: The newly created node.
  /// - Complexity: O(1)
  @discardableResult
  public func append(_ value: Element) -> Node {
    let node = Node(value: value)
    
    if let tailNode = tail {
      tailNode.next = node
      node.previous = tailNode
      tail = node
    } else {
      head = node
      tail = node
    }
    
    count += 1
    return node
  }
  
  /// Inserts an element after the given node.
  ///
  /// - Parameters:
  ///   - value: The value to insert.
  ///   - node: The node after which to insert.
  /// - Returns: The newly created node.
  /// - Complexity: O(1)
  @discardableResult
  public func insert(_ value: Element, after node: Node) -> Node {
    let newNode = Node(value: value)
    
    newNode.previous = node
    newNode.next = node.next
    node.next?.previous = newNode
    node.next = newNode
    
    if node === tail {
      tail = newNode
    }
    
    count += 1
    return newNode
  }
  
  /// Inserts an element before the given node.
  ///
  /// - Parameters:
  ///   - value: The value to insert.
  ///   - node: The node before which to insert.
  /// - Returns: The newly created node.
  /// - Complexity: O(1)
  @discardableResult
  public func insert(_ value: Element, before node: Node) -> Node {
    let newNode = Node(value: value)
    
    newNode.next = node
    newNode.previous = node.previous
    node.previous?.next = newNode
    node.previous = newNode
    
    if node === head {
      head = newNode
    }
    
    count += 1
    return newNode
  }
  
  // MARK: - Removing Elements
  
  /// Removes a node from the list.
  ///
  /// - Parameter node: The node to remove.
  /// - Returns: The value that was stored in the node.
  /// - Complexity: O(1)
  @discardableResult
  public func remove(_ node: Node) -> Element {
    let prev = node.previous
    let next = node.next
    
    prev?.next = next
    next?.previous = prev
    
    if node === head {
      head = next
    }
    if node === tail {
      tail = prev
    }
    
    node.previous = nil
    node.next = nil
    count -= 1
    
    return node.value
  }
  
  /// Removes and returns the first element.
  ///
  /// - Returns: The first element, or `nil` if the list is empty.
  /// - Complexity: O(1)
  @discardableResult
  public func removeFirst() -> Element? {
    guard let node = head else { return nil }
    return remove(node)
  }
  
  /// Removes and returns the last element.
  ///
  /// - Returns: The last element, or `nil` if the list is empty.
  /// - Complexity: O(1)
  @discardableResult
  public func removeLast() -> Element? {
    guard let node = tail else { return nil }
    return remove(node)
  }
  
  /// Removes all elements from the list.
  ///
  /// - Complexity: O(n)
  public func removeAll() {
    // Break retain cycles
    var current = head
    while let node = current {
      let next = node.next
      node.next = nil
      node.previous = nil
      current = next
    }
    
    head = nil
    tail = nil
    count = 0
  }
  
  // MARK: - Accessing Elements
  
  /// Returns the node at the specified index.
  ///
  /// - Parameter index: The position of the node (0-indexed).
  /// - Returns: The node at the index, or `nil` if out of bounds.
  /// - Complexity: O(n)
  public func node(at index: Int) -> Node? {
    guard index >= 0 && index < count else { return nil }
    
    // Optimize by starting from closer end
    if index < count / 2 {
      var current = head
      for _ in 0..<index {
        current = current?.next
      }
      return current
    } else {
      var current = tail
      for _ in 0..<(count - 1 - index) {
        current = current?.previous
      }
      return current
    }
  }
  
  /// Accesses the element at the specified position.
  ///
  /// - Parameter index: The position of the element (0-indexed).
  /// - Complexity: O(n)
  /// - Precondition: `index` must be in the range `0..<count`.
  public subscript(index: Int) -> Element {
    get {
      guard let node = node(at: index) else {
        preconditionFailure("Index out of bounds")
      }
      return node.value
    }
    set {
      guard let node = node(at: index) else {
        preconditionFailure("Index out of bounds")
      }
      node.value = newValue
    }
  }
  
  // MARK: - Searching
  
  /// Returns the first node containing the specified value.
  ///
  /// - Parameter value: The value to search for.
  /// - Returns: The first node containing the value, or `nil`.
  /// - Complexity: O(n)
  public func firstNode(where predicate: (Element) throws -> Bool) rethrows -> Node? {
    var current = head
    while let node = current {
      if try predicate(node.value) {
        return node
      }
      current = node.next
    }
    return nil
  }
  
  /// Creates a copy of the linked list.
  ///
  /// - Returns: A new linked list with the same elements.
  /// - Complexity: O(n)
  public func copy() -> LinkedList {
    let newList = LinkedList()
    for element in self {
      newList.append(element)
    }
    return newList
  }
  
  /// Reverses the linked list in place.
  ///
  /// - Complexity: O(n)
  public func reverse() {
    var current = head
    var temp: Node?
    
    while let node = current {
      temp = node.previous
      node.previous = node.next
      node.next = temp
      current = node.previous
    }
    
    temp = head
    head = tail
    tail = temp
  }
}

// MARK: - Sequence Conformance

extension LinkedList: Sequence {
  /// An iterator that traverses the list from head to tail.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var current: Node?
    
    @inlinable
    internal init(_ list: LinkedList) {
      self.current = list.head
    }
    
    @inlinable
    public mutating func next() -> Element? {
      guard let node = current else { return nil }
      current = node.next
      return node.value
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension LinkedList: ExpressibleByArrayLiteral {
  public convenience init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension LinkedList: CustomStringConvertible {
  public var description: String {
    let contents = map { "\($0)" }.joined(separator: " <-> ")
    return "LinkedList<\(Element.self)>([\(contents)])"
  }
}

// MARK: - CustomDebugStringConvertible

extension LinkedList: CustomDebugStringConvertible {
  public var debugDescription: String {
    "LinkedList<\(Element.self)>(count: \(count), head: \(head?.value as Any), tail: \(tail?.value as Any))"
  }
}

// MARK: - Countable Conformance

extension LinkedList: Countable {}

// MARK: - Equatable (when Element is Equatable)

extension LinkedList where Element: Equatable {
  /// Checks whether the list contains the specified element.
  ///
  /// - Parameter element: The element to search for.
  /// - Returns: `true` if the element is found.
  /// - Complexity: O(n)
  public func contains(_ element: Element) -> Bool {
    firstNode { $0 == element } != nil
  }
  
  /// Returns the first node containing the specified value.
  ///
  /// - Parameter value: The value to search for.
  /// - Returns: The first node containing the value, or `nil`.
  /// - Complexity: O(n)
  public func firstNode(of value: Element) -> Node? {
    firstNode { $0 == value }
  }
  
  /// Removes the first occurrence of the specified element.
  ///
  /// - Parameter element: The element to remove.
  /// - Returns: `true` if an element was removed.
  /// - Complexity: O(n)
  @discardableResult
  public func removeFirst(_ element: Element) -> Bool {
    guard let node = firstNode(of: element) else { return false }
    remove(node)
    return true
  }
}

// MARK: - Equatable (when Element is Equatable)

extension LinkedList: Equatable where Element: Equatable {
  /// Checks equality with another linked list.
  public static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    var lhsCurrent = lhs.head
    var rhsCurrent = rhs.head
    
    while let lhsNode = lhsCurrent, let rhsNode = rhsCurrent {
      if lhsNode.value != rhsNode.value {
        return false
      }
      lhsCurrent = lhsNode.next
      rhsCurrent = rhsNode.next
    }
    
    return true
  }
}

// MARK: - Hashable (when Element is Hashable)

extension LinkedList: Hashable where Element: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(count)
    for element in self {
      hasher.combine(element)
    }
  }
}
