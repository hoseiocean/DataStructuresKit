import Testing
@testable import DataStructuresKit

@Suite("LRUCache Tests")
struct LRUCacheTests {
  
  // MARK: - Initialization
  
  @Test("Empty cache initialization")
  func testEmptyInit() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    #expect(cache.isEmpty)
    #expect(cache.count == 0)
    #expect(cache.capacity == 10)
    #expect(!cache.isFull)
  }
  
  // MARK: - Get and Set
  
  @Test("Set and get value")
  func testSetGet() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    
    #expect(cache.get("a") == 1)
    #expect(cache.get("b") == 2)
    #expect(cache.get("c") == nil)
  }
  
  @Test("Update existing key")
  func testUpdateExisting() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("a", value: 42)
    
    #expect(cache.get("a") == 42)
    #expect(cache.count == 1)
  }
  
  @Test("Subscript access")
  func testSubscript() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache["a"] = 1
    cache["b"] = 2
    
    #expect(cache["a"] == 1)
    #expect(cache["b"] == 2)
    
    cache["a"] = nil  // Remove
    #expect(cache["a"] == nil)
  }
  
  // MARK: - LRU Eviction
  
  @Test("Evicts least recently used when full")
  func testEviction() {
    let cache = LRUCache<String, Int>(capacity: 3)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    // Cache is now full: a, b, c
    
    cache.set("d", value: 4)  // Should evict "a" (LRU)
    
    #expect(cache.get("a") == nil)
    #expect(cache.get("b") == 2)
    #expect(cache.get("c") == 3)
    #expect(cache.get("d") == 4)
  }
  
  @Test("Access updates recency")
  func testAccessUpdatesRecency() {
    let cache = LRUCache<String, Int>(capacity: 3)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    
    // Access "a" to make it most recently used
    _ = cache.get("a")
    
    // Add new item, should evict "b" (now LRU)
    cache.set("d", value: 4)
    
    #expect(cache.get("a") == 1)  // Still exists
    #expect(cache.get("b") == nil) // Evicted
    #expect(cache.get("c") == 3)
    #expect(cache.get("d") == 4)
  }
  
  @Test("Set updates recency")
  func testSetUpdatesRecency() {
    let cache = LRUCache<String, Int>(capacity: 3)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    
    // Update "a" to make it most recently used
    cache.set("a", value: 100)
    
    // Add new item, should evict "b" (now LRU)
    cache.set("d", value: 4)
    
    #expect(cache.get("a") == 100)
    #expect(cache.get("b") == nil)
  }
  
  // MARK: - Remove
  
  @Test("Remove key")
  func testRemove() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    
    let removed = cache.remove("a")
    
    #expect(removed == 1)
    #expect(cache.get("a") == nil)
    #expect(cache.count == 1)
  }
  
  @Test("Remove non-existent key")
  func testRemoveNonExistent() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    let removed = cache.remove("x")
    
    #expect(removed == nil)
  }
  
  // MARK: - Clear
  
  @Test("Clear cache")
  func testClear() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    
    cache.clear()
    
    #expect(cache.isEmpty)
    #expect(cache.count == 0)
    #expect(cache.get("a") == nil)
  }
  
  // MARK: - Contains
  
  @Test("Contains without affecting recency")
  func testContains() {
    let cache = LRUCache<String, Int>(capacity: 3)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    
    // Check contains (should NOT update recency)
    #expect(cache.contains("a"))
    #expect(!cache.contains("x"))
    
    // Verify "a" is still LRU by adding new item
    cache.set("d", value: 4)
    
    // If contains updated recency, "b" would be evicted
    // Since it doesn't, "a" should be evicted
    #expect(cache.get("a") == nil)
  }
  
  // MARK: - Keys
  
  @Test("Keys in MRU to LRU order")
  func testKeys() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    _ = cache.get("a")  // Make "a" MRU
    
    let keys = cache.keys
    
    #expect(keys.first == "a")  // Most recently used
    #expect(keys.last == "b")   // Least recently used
  }
  
  // MARK: - Iteration
  
  @Test("Iteration in MRU to LRU order")
  func testIteration() {
    let cache = LRUCache<String, Int>(capacity: 10)
    
    cache.set("a", value: 1)
    cache.set("b", value: 2)
    cache.set("c", value: 3)
    
    var pairs: [(String, Int)] = []
    for (key, value) in cache {
      pairs.append((key, value))
    }
    
    #expect(pairs.count == 3)
    #expect(pairs[0].0 == "c")  // MRU
    #expect(pairs[2].0 == "a")  // LRU
  }
  
  // MARK: - Edge Cases
  
  @Test("Capacity 1")
  func testCapacityOne() {
    let cache = LRUCache<String, Int>(capacity: 1)
    
    cache.set("a", value: 1)
    #expect(cache.get("a") == 1)
    
    cache.set("b", value: 2)
    #expect(cache.get("a") == nil)
    #expect(cache.get("b") == 2)
  }
  
  @Test("Full cache status")
  func testIsFull() {
    let cache = LRUCache<String, Int>(capacity: 2)
    
    #expect(!cache.isFull)
    
    cache.set("a", value: 1)
    #expect(!cache.isFull)
    
    cache.set("b", value: 2)
    #expect(cache.isFull)
  }
}
