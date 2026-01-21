// MARK: - LRUCache
// A Least Recently Used cache with O(1) operations.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - shared mutable cache ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(1) get/set/remove verified ✓

/// A Least Recently Used (LRU) cache with fixed capacity.
///
/// `LRUCache` automatically evicts the least recently accessed item when
/// the cache reaches capacity. Both `get` and `set` operations run in O(1).
///
/// ## Use Cases
///
/// - Image caching in apps
/// - Database query caching
/// - API response caching
/// - Memoization of expensive computations
///
/// ## Example
///
/// ```swift
/// let cache = LRUCache<String, UIImage>(capacity: 100)
///
/// // Store an image
/// cache.set("profile_123", value: profileImage)
///
/// // Retrieve (marks as recently used)
/// if let image = cache.get("profile_123") {
///     imageView.image = image
/// }
///
/// // When capacity is reached, least recently used items are evicted
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | get(_:) | O(1) |
/// | set(_:value:) | O(1) |
/// | remove(_:) | O(1) |
/// | clear() | O(n) |
///
/// ## Thread Safety
///
/// `LRUCache` is NOT thread-safe. For concurrent access, use external
/// synchronization or wrap in an actor.
public final class LRUCache<Key: Hashable, Value> {
  
  // MARK: - Node (Doubly Linked List)
  
  private final class Node {
    let key: Key
    var value: Value
    var previous: Node?
    var next: Node?
    
    init(key: Key, value: Value) {
      self.key = key
      self.value = value
    }
  }
  
  // MARK: - Properties
  
  /// The maximum number of items the cache can hold.
  public let capacity: Int
  
  /// The current number of items in the cache.
  public private(set) var count: Int = 0
  
  /// A Boolean value indicating whether the cache is empty.
  @inlinable
  public var isEmpty: Bool { count == 0 }
  
  /// A Boolean value indicating whether the cache is full.
  @inlinable
  public var isFull: Bool { count >= capacity }
  
  /// Hash map for O(1) lookup.
  private var cache: [Key: Node] = [:]
  
  /// Head of the doubly linked list (most recently used).
  private var head: Node?
  
  /// Tail of the doubly linked list (least recently used).
  private var tail: Node?
  
  // MARK: - Initialization
  
  /// Creates an LRU cache with the specified capacity.
  ///
  /// - Parameter capacity: The maximum number of items.
  /// - Precondition: `capacity` must be greater than 0.
  public init(capacity: Int) {
    precondition(capacity > 0, "LRUCache capacity must be greater than 0")
    self.capacity = capacity
  }
  
  // MARK: - Operations
  
  /// Retrieves a value and marks it as recently used.
  ///
  /// - Parameter key: The key to look up.
  /// - Returns: The value if found, `nil` otherwise.
  /// - Complexity: O(1)
  public func get(_ key: Key) -> Value? {
    guard let node = cache[key] else { return nil }
    moveToHead(node)
    return node.value
  }
  
  /// Stores a value, evicting the LRU item if at capacity.
  ///
  /// - Parameters:
  ///   - key: The key to store.
  ///   - value: The value to store.
  /// - Complexity: O(1)
  public func set(_ key: Key, value: Value) {
    if let node = cache[key] {
      // Update existing
      node.value = value
      moveToHead(node)
    } else {
      // Insert new
      let node = Node(key: key, value: value)
      cache[key] = node
      addToHead(node)
      count += 1
      
      // Evict if over capacity
      if count > capacity {
        if let lru = removeTail() {
          cache.removeValue(forKey: lru.key)
          count -= 1
        }
      }
    }
  }
  
  /// Removes a value from the cache.
  ///
  /// - Parameter key: The key to remove.
  /// - Returns: The removed value if found.
  /// - Complexity: O(1)
  @discardableResult
  public func remove(_ key: Key) -> Value? {
    guard let node = cache.removeValue(forKey: key) else { return nil }
    removeNode(node)
    count -= 1
    return node.value
  }
  
  /// Removes all items from the cache.
  ///
  /// - Complexity: O(n)
  public func clear() {
    cache.removeAll()
    head = nil
    tail = nil
    count = 0
  }
  
  /// Returns whether the cache contains the key.
  ///
  /// This does NOT affect recency.
  ///
  /// - Complexity: O(1)
  public func contains(_ key: Key) -> Bool {
    cache[key] != nil
  }
  
  /// Returns all keys in the cache, from most to least recently used.
  ///
  /// - Complexity: O(n)
  public var keys: [Key] {
    var result: [Key] = []
    result.reserveCapacity(count)
    var current = head
    while let node = current {
      result.append(node.key)
      current = node.next
    }
    return result
  }
  
  /// Subscript access to cache values.
  ///
  /// Getting marks the item as recently used.
  /// Setting `nil` removes the item.
  public subscript(key: Key) -> Value? {
    get { get(key) }
    set {
      if let value = newValue {
        set(key, value: value)
      } else {
        remove(key)
      }
    }
  }
  
  // MARK: - Private Linked List Operations
  
  private func addToHead(_ node: Node) {
    node.previous = nil
    node.next = head
    head?.previous = node
    head = node
    
    if tail == nil {
      tail = node
    }
  }
  
  private func removeNode(_ node: Node) {
    node.previous?.next = node.next
    node.next?.previous = node.previous
    
    if node === head {
      head = node.next
    }
    if node === tail {
      tail = node.previous
    }
    
    node.previous = nil
    node.next = nil
  }
  
  private func moveToHead(_ node: Node) {
    guard node !== head else { return }
    removeNode(node)
    addToHead(node)
  }
  
  private func removeTail() -> Node? {
    guard let node = tail else { return nil }
    removeNode(node)
    return node
  }
}

// MARK: - CustomStringConvertible

extension LRUCache: CustomStringConvertible {
  public var description: String {
    let items = keys.prefix(5).map { "\($0)" }.joined(separator: ", ")
    let suffix = count > 5 ? ", ..." : ""
    return "LRUCache<\(Key.self), \(Value.self)>(\(count)/\(capacity), MRU→LRU: [\(items)\(suffix)])"
  }
}

// MARK: - Sequence Conformance

extension LRUCache: Sequence {
  /// An iterator that traverses from most to least recently used.
  public struct Iterator: IteratorProtocol {
    private var current: Node?
    
    fileprivate init(_ cache: LRUCache) {
      self.current = cache.head
    }
    
    public mutating func next() -> (key: Key, value: Value)? {
      guard let node = current else { return nil }
      current = node.next
      return (node.key, node.value)
    }
  }
  
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}
