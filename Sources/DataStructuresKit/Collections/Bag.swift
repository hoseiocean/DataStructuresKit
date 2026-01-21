// MARK: - Bag (Multiset)
// A collection that counts occurrences of elements (allows duplicates).
//
// ADR Compliance:
// - ADR-001: Value type with Copy-on-Write ✓
// - ADR-002: Full API documentation with DocC ✓
// - ADR-003: O(1) for all primary operations verified ✓

/// A collection that stores elements with their occurrence counts.
///
/// `Bag` (also known as a Multiset) is similar to `Set` but allows duplicate
/// elements by tracking how many times each element has been added.
///
/// ## Overview
///
/// Unlike `Set`, which stores each element only once, `Bag` maintains a count
/// for each unique element. This makes it ideal for counting occurrences,
/// inventories, histograms, and similar use cases.
///
/// ## Example
///
/// ```swift
/// var bag = Bag<String>()
/// bag.insert("apple")
/// bag.insert("apple")
/// bag.insert("banana")
///
/// print(bag.count(of: "apple"))  // 2
/// print(bag.count(of: "banana")) // 1
/// print(bag.count(of: "orange")) // 0
/// print(bag.totalCount)          // 3
/// print(bag.uniqueCount)         // 2
///
/// bag.remove("apple")
/// print(bag.count(of: "apple"))  // 1
///
/// bag.removeAll("apple")
/// print(bag.count(of: "apple"))  // 0
/// ```
///
/// ## Use Cases
///
/// - **Word frequency**: Count word occurrences in text
/// - **Inventory systems**: Track quantities of items
/// - **Voting/Polling**: Count votes per option
/// - **Shopping carts**: Multiple quantities of products
/// - **Histograms**: Frequency distribution of values
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | insert(_:) | O(1) |
/// | insert(_:count:) | O(1) |
/// | remove(_:) | O(1) |
/// | removeAll(_:) | O(1) |
/// | count(of:) | O(1) |
/// | contains(_:) | O(1) |
/// | uniqueCount | O(1) |
/// | totalCount | O(1) |
///
/// ## Topics
///
/// ### Creating a Bag
///
/// - ``init()``
/// - ``init(_:)-81gxl``
/// - ``init(_:)-820ce``
///
/// ### Adding Elements
///
/// - ``insert(_:)``
/// - ``insert(_:count:)``
///
/// ### Removing Elements
///
/// - ``remove(_:)``
/// - ``remove(_:count:)``
/// - ``removeAll(_:)``
/// - ``removeAll(keepingCapacity:)``
///
/// ### Querying
///
/// - ``count(of:)``
/// - ``contains(_:)``
/// - ``totalCount``
/// - ``uniqueCount``
/// - ``isEmpty``
/// - ``mostCommon(_:)``
public struct Bag<Element: Hashable> {
  
  // MARK: - Storage (Copy-on-Write)
  
  @usableFromInline
  internal final class Storage {
    @usableFromInline
    internal var counts: [Element: Int]
    
    @usableFromInline
    internal var totalCount: Int
    
    @inlinable
    internal init() {
      self.counts = [:]
      self.totalCount = 0
    }
    
    @inlinable
    internal init(counts: [Element: Int], totalCount: Int) {
      self.counts = counts
      self.totalCount = totalCount
    }
    
    @inlinable
    internal func copy() -> Storage {
      Storage(counts: counts, totalCount: totalCount)
    }
  }
  
  @usableFromInline
  internal var storage: Storage
  
  // MARK: - Copy-on-Write
  
  /// Ensures unique ownership of storage before mutation.
  @inlinable
  internal mutating func ensureUnique() {
    if !isKnownUniquelyReferenced(&storage) {
      storage = storage.copy()
    }
  }
  
  // MARK: - Initialization
  
  /// Creates an empty bag.
  ///
  /// - Complexity: O(1)
  @inlinable
  public init() {
    self.storage = Storage()
  }
  
  /// Creates a bag from a sequence of elements.
  ///
  /// Each element in the sequence is added once to the bag.
  ///
  /// - Parameter elements: The elements to add.
  /// - Complexity: O(n) where n is the length of the sequence.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let words = ["apple", "banana", "apple", "cherry", "apple"]
  /// let bag = Bag(words)
  /// print(bag.count(of: "apple")) // 3
  /// ```
  @inlinable
  public init<S: Sequence>(_ elements: S) where S.Element == Element {
    self.storage = Storage()
    for element in elements {
      storage.counts[element, default: 0] += 1
      storage.totalCount += 1
    }
  }
  
  /// Creates a bag from a dictionary of element counts.
  ///
  /// - Parameter counts: A dictionary mapping elements to their counts.
  /// - Precondition: All counts must be positive.
  /// - Complexity: O(n) where n is the number of unique elements.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let bag = Bag(["apple": 3, "banana": 2])
  /// print(bag.totalCount) // 5
  /// ```
  public init(_ counts: [Element: Int]) {
    precondition(counts.values.allSatisfy { $0 > 0 }, "All counts must be positive")
    let total = counts.values.reduce(0, +)
    self.storage = Storage(counts: counts, totalCount: total)
  }
  
  // MARK: - Properties
  
  /// The total number of elements, counting duplicates.
  ///
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag(["a", "a", "b"])
  /// print(bag.totalCount) // 3
  /// ```
  @inlinable
  public var totalCount: Int {
    storage.totalCount
  }
  
  /// The number of unique elements.
  ///
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag(["a", "a", "b"])
  /// print(bag.uniqueCount) // 2
  /// ```
  @inlinable
  public var uniqueCount: Int {
    storage.counts.count
  }
  
  /// A Boolean value indicating whether the bag is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    storage.totalCount == 0
  }
  
  /// All unique elements in the bag.
  ///
  /// - Complexity: O(1) to access, O(n) to iterate.
  @inlinable
  public var uniqueElements: Dictionary<Element, Int>.Keys {
    storage.counts.keys
  }
  
  // MARK: - Querying
  
  /// Returns the number of occurrences of the specified element.
  ///
  /// - Parameter element: The element to count.
  /// - Returns: The count, or 0 if the element is not present.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// let bag = Bag(["a", "a", "b"])
  /// print(bag.count(of: "a")) // 2
  /// print(bag.count(of: "c")) // 0
  /// ```
  @inlinable
  public func count(of element: Element) -> Int {
    storage.counts[element] ?? 0
  }
  
  /// Returns whether the bag contains the specified element.
  ///
  /// - Parameter element: The element to check.
  /// - Returns: `true` if the element exists with count > 0.
  /// - Complexity: O(1)
  @inlinable
  public func contains(_ element: Element) -> Bool {
    storage.counts[element] != nil
  }
  
  /// Returns the most common elements with their counts.
  ///
  /// - Parameter n: The maximum number of elements to return.
  /// - Returns: An array of (element, count) tuples, sorted by count descending.
  /// - Complexity: O(k log k) where k is the number of unique elements.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let bag = Bag(["a", "a", "a", "b", "b", "c"])
  /// print(bag.mostCommon(2)) // [("a", 3), ("b", 2)]
  /// ```
  public func mostCommon(_ n: Int? = nil) -> [(element: Element, count: Int)] {
    let sorted = storage.counts.sorted { $0.value > $1.value }
    if let n = n {
      return Array(sorted.prefix(n)).map { ($0.key, $0.value) }
    }
    return sorted.map { ($0.key, $0.value) }
  }
  
  // MARK: - Adding Elements
  
  /// Inserts a single occurrence of an element.
  ///
  /// - Parameter element: The element to insert.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag<String>()
  /// bag.insert("apple")
  /// bag.insert("apple")
  /// print(bag.count(of: "apple")) // 2
  /// ```
  @inlinable
  public mutating func insert(_ element: Element) {
    insert(element, count: 1)
  }
  
  /// Inserts multiple occurrences of an element.
  ///
  /// - Parameters:
  ///   - element: The element to insert.
  ///   - count: The number of occurrences to add. Must be positive.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag<String>()
  /// bag.insert("apple", count: 5)
  /// print(bag.count(of: "apple")) // 5
  /// ```
  @inlinable
  public mutating func insert(_ element: Element, count: Int) {
    precondition(count > 0, "Count must be positive")
    ensureUnique()
    storage.counts[element, default: 0] += count
    storage.totalCount += count
  }
  
  // MARK: - Removing Elements
  
  /// Removes a single occurrence of an element.
  ///
  /// - Parameter element: The element to remove.
  /// - Returns: The number of occurrences actually removed (0 or 1).
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag(["a", "a", "a"])
  /// bag.remove("a")
  /// print(bag.count(of: "a")) // 2
  /// ```
  @inlinable
  @discardableResult
  public mutating func remove(_ element: Element) -> Int {
    remove(element, count: 1)
  }
  
  /// Removes multiple occurrences of an element.
  ///
  /// If `count` exceeds the current count, all occurrences are removed.
  ///
  /// - Parameters:
  ///   - element: The element to remove.
  ///   - count: The maximum number of occurrences to remove.
  /// - Returns: The number of occurrences actually removed.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag(["a", "a", "a"])
  /// let removed = bag.remove("a", count: 2)
  /// print(removed)              // 2
  /// print(bag.count(of: "a"))   // 1
  /// ```
  @inlinable
  @discardableResult
  public mutating func remove(_ element: Element, count: Int) -> Int {
    precondition(count > 0, "Count must be positive")
    guard let current = storage.counts[element] else { return 0 }
    
    ensureUnique()
    let removed = Swift.min(current, count)
    
    if current <= count {
      storage.counts.removeValue(forKey: element)
    } else {
      storage.counts[element] = current - count
    }
    
    storage.totalCount -= removed
    return removed
  }
  
  /// Removes all occurrences of an element.
  ///
  /// - Parameter element: The element to remove completely.
  /// - Returns: The number of occurrences removed.
  /// - Complexity: O(1)
  ///
  /// ## Example
  ///
  /// ```swift
  /// var bag = Bag(["a", "a", "a", "b"])
  /// let removed = bag.removeAll("a")
  /// print(removed)            // 3
  /// print(bag.contains("a"))  // false
  /// ```
  @inlinable
  @discardableResult
  public mutating func removeAll(_ element: Element) -> Int {
    guard let count = storage.counts[element] else { return 0 }
    
    ensureUnique()
    storage.counts.removeValue(forKey: element)
    storage.totalCount -= count
    return count
  }
  
  /// Removes all elements from the bag.
  ///
  /// - Parameter keepingCapacity: If `true`, the storage capacity is preserved.
  /// - Complexity: O(n)
  @inlinable
  public mutating func removeAll(keepingCapacity: Bool = false) {
    ensureUnique()
    storage.counts.removeAll(keepingCapacity: keepingCapacity)
    storage.totalCount = 0
  }
  
  // MARK: - Set Operations
  
  /// Returns a new bag containing elements from both bags.
  ///
  /// The count of each element is the sum of counts in both bags.
  ///
  /// - Parameter other: Another bag.
  /// - Returns: A new bag with combined counts.
  /// - Complexity: O(n) where n is the size of `other`.
  public func union(_ other: Bag) -> Bag {
    var result = self
    for (element, count) in other.storage.counts {
      result.insert(element, count: count)
    }
    return result
  }
  
  /// Returns a new bag containing elements common to both bags.
  ///
  /// The count of each element is the minimum of counts in both bags.
  ///
  /// - Parameter other: Another bag.
  /// - Returns: A new bag with minimum counts.
  /// - Complexity: O(n) where n is the number of unique elements.
  public func intersection(_ other: Bag) -> Bag {
    var result = Bag()
    for (element, count) in storage.counts {
      let otherCount = other.count(of: element)
      if otherCount > 0 {
        result.insert(element, count: Swift.min(count, otherCount))
      }
    }
    return result
  }
  
  /// Returns a new bag with elements in this bag but not in the other.
  ///
  /// The count is reduced by the other bag's count (minimum 0).
  ///
  /// - Parameter other: Another bag.
  /// - Returns: A new bag with subtracted counts.
  /// - Complexity: O(n)
  public func subtracting(_ other: Bag) -> Bag {
    var result = self
    for (element, count) in other.storage.counts {
      _ = result.remove(element, count: count)
    }
    return result
  }
}

// MARK: - Sequence Conformance

extension Bag: Sequence {
  /// An iterator that returns each element the number of times it appears.
  public struct Iterator: IteratorProtocol {
    private var countsIterator: Dictionary<Element, Int>.Iterator
    private var currentElement: Element?
    private var remaining: Int = 0
    
    internal init(_ bag: Bag) {
      self.countsIterator = bag.storage.counts.makeIterator()
      advanceToNext()
    }
    
    private mutating func advanceToNext() {
      if let next = countsIterator.next() {
        currentElement = next.key
        remaining = next.value
      } else {
        currentElement = nil
        remaining = 0
      }
    }
    
    public mutating func next() -> Element? {
      guard let element = currentElement, remaining > 0 else {
        return nil
      }
      
      remaining -= 1
      if remaining == 0 {
        advanceToNext()
      }
      
      return element
    }
  }
  
  /// Returns an iterator over all elements, including duplicates.
  ///
  /// Each element is yielded the number of times it appears in the bag.
  ///
  /// - Complexity: O(1) to create, O(totalCount) to fully iterate.
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension Bag: ExpressibleByArrayLiteral {
  /// Creates a bag from an array literal.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let bag: Bag = ["a", "a", "b", "c"]
  /// print(bag.count(of: "a")) // 2
  /// ```
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension Bag: ExpressibleByDictionaryLiteral {
  /// Creates a bag from a dictionary literal.
  ///
  /// ## Example
  ///
  /// ```swift
  /// let bag: Bag = ["apple": 3, "banana": 2]
  /// print(bag.totalCount) // 5
  /// ```
  public init(dictionaryLiteral elements: (Element, Int)...) {
    self.storage = Storage()
    for (element, count) in elements {
      precondition(count > 0, "All counts must be positive")
      storage.counts[element] = count
      storage.totalCount += count
    }
  }
}

// MARK: - Equatable

extension Bag: Equatable {
  public static func == (lhs: Bag, rhs: Bag) -> Bool {
    lhs.storage.counts == rhs.storage.counts
  }
}

// MARK: - Hashable

extension Bag: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(storage.counts)
  }
}

// MARK: - CustomStringConvertible

extension Bag: CustomStringConvertible {
  public var description: String {
    let items = storage.counts
      .sorted { $0.value > $1.value }
      .prefix(5)
      .map { "\($0.key): \($0.value)" }
      .joined(separator: ", ")
    let suffix = uniqueCount > 5 ? ", ..." : ""
    return "Bag<\(Element.self)>([\(items)\(suffix)], total: \(totalCount))"
  }
}

// MARK: - CustomDebugStringConvertible

extension Bag: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Bag<\(Element.self)>(uniqueCount: \(uniqueCount), totalCount: \(totalCount), counts: \(storage.counts))"
  }
}

// MARK: - Sendable

extension Bag: Sendable where Element: Sendable {}
extension Bag.Storage: @unchecked Sendable where Element: Sendable {}

// MARK: - Countable

extension Bag: Countable {
  /// Conformance to Countable protocol.
  /// Returns the total count (including duplicates).
  @inlinable
  public var count: Int {
    totalCount
  }
}
