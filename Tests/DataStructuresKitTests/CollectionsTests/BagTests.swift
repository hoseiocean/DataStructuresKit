import Testing
@testable import DataStructuresKit

@Suite("Bag Tests")
struct BagTests {
  
  // MARK: - Initialization
  
  @Test("Empty bag initialization")
  func testEmptyInit() {
    let bag = Bag<String>()
    
    #expect(bag.isEmpty)
    #expect(bag.totalCount == 0)
    #expect(bag.uniqueCount == 0)
  }
  
  @Test("Initialization from sequence")
  func testSequenceInit() {
    let bag = Bag(["a", "a", "b", "c", "c", "c"])
    
    #expect(bag.totalCount == 6)
    #expect(bag.uniqueCount == 3)
    #expect(bag.count(of: "a") == 2)
    #expect(bag.count(of: "b") == 1)
    #expect(bag.count(of: "c") == 3)
  }
  
  @Test("Initialization from dictionary")
  func testDictionaryInit() {
    let bag = Bag(["apple": 3, "banana": 2])
    
    #expect(bag.totalCount == 5)
    #expect(bag.uniqueCount == 2)
    #expect(bag.count(of: "apple") == 3)
    #expect(bag.count(of: "banana") == 2)
  }
  
  @Test("Array literal initialization")
  func testArrayLiteralInit() {
    let bag: Bag = ["x", "x", "y"]
    
    #expect(bag.count(of: "x") == 2)
    #expect(bag.count(of: "y") == 1)
  }
  
  @Test("Dictionary literal initialization")
  func testDictionaryLiteralInit() {
    let bag: Bag = ["a": 5, "b": 3]
    
    #expect(bag.count(of: "a") == 5)
    #expect(bag.count(of: "b") == 3)
    #expect(bag.totalCount == 8)
  }
  
  // MARK: - Insert Operations
  
  @Test("Insert single element")
  func testInsertSingle() {
    var bag = Bag<String>()
    
    bag.insert("apple")
    
    #expect(bag.count(of: "apple") == 1)
    #expect(bag.totalCount == 1)
  }
  
  @Test("Insert multiple times")
  func testInsertMultipleTimes() {
    var bag = Bag<String>()
    
    bag.insert("apple")
    bag.insert("apple")
    bag.insert("apple")
    
    #expect(bag.count(of: "apple") == 3)
    #expect(bag.uniqueCount == 1)
  }
  
  @Test("Insert with count")
  func testInsertWithCount() {
    var bag = Bag<String>()
    
    bag.insert("apple", count: 5)
    
    #expect(bag.count(of: "apple") == 5)
    #expect(bag.totalCount == 5)
  }
  
  // MARK: - Remove Operations
  
  @Test("Remove single occurrence")
  func testRemoveSingle() {
    var bag = Bag(["a", "a", "a"])
    
    let removed = bag.remove("a")
    
    #expect(removed == 1)
    #expect(bag.count(of: "a") == 2)
  }
  
  @Test("Remove multiple occurrences")
  func testRemoveMultiple() {
    var bag = Bag(["a", "a", "a", "a", "a"])
    
    let removed = bag.remove("a", count: 3)
    
    #expect(removed == 3)
    #expect(bag.count(of: "a") == 2)
  }
  
  @Test("Remove more than available")
  func testRemoveMoreThanAvailable() {
    var bag = Bag(["a", "a"])
    
    let removed = bag.remove("a", count: 10)
    
    #expect(removed == 2)
    #expect(bag.count(of: "a") == 0)
    #expect(!bag.contains("a"))
  }
  
  @Test("Remove non-existent element")
  func testRemoveNonExistent() {
    var bag = Bag(["a"])
    
    let removed = bag.remove("b")
    
    #expect(removed == 0)
    #expect(bag.totalCount == 1)
  }
  
  @Test("Remove all occurrences of element")
  func testRemoveAllElement() {
    var bag = Bag(["a", "a", "a", "b"])
    
    let removed = bag.removeAll("a")
    
    #expect(removed == 3)
    #expect(!bag.contains("a"))
    #expect(bag.contains("b"))
    #expect(bag.totalCount == 1)
  }
  
  @Test("Remove all elements")
  func testRemoveAll() {
    var bag = Bag(["a", "a", "b", "c"])
    
    bag.removeAll()
    
    #expect(bag.isEmpty)
    #expect(bag.totalCount == 0)
    #expect(bag.uniqueCount == 0)
  }
  
  // MARK: - Query Operations
  
  @Test("Contains")
  func testContains() {
    let bag = Bag(["a", "b"])
    
    #expect(bag.contains("a"))
    #expect(bag.contains("b"))
    #expect(!bag.contains("c"))
  }
  
  @Test("Count of element")
  func testCountOf() {
    let bag = Bag(["a", "a", "a", "b"])
    
    #expect(bag.count(of: "a") == 3)
    #expect(bag.count(of: "b") == 1)
    #expect(bag.count(of: "c") == 0)
  }
  
  @Test("Most common elements")
  func testMostCommon() {
    let bag = Bag(["a", "a", "a", "b", "b", "c"])
    
    let top2 = bag.mostCommon(2)
    
    #expect(top2.count == 2)
    #expect(top2[0].element == "a")
    #expect(top2[0].count == 3)
    #expect(top2[1].element == "b")
    #expect(top2[1].count == 2)
  }
  
  @Test("Unique elements")
  func testUniqueElements() {
    let bag = Bag(["a", "a", "b", "c"])
    
    let unique = Set(bag.uniqueElements)
    
    #expect(unique == Set(["a", "b", "c"]))
  }
  
  // MARK: - Set Operations
  
  @Test("Union")
  func testUnion() {
    let bag1 = Bag(["a", "a", "b"])
    let bag2 = Bag(["a", "c", "c"])
    
    let union = bag1.union(bag2)
    
    #expect(union.count(of: "a") == 3)
    #expect(union.count(of: "b") == 1)
    #expect(union.count(of: "c") == 2)
  }
  
  @Test("Intersection")
  func testIntersection() {
    let bag1 = Bag(["a", "a", "a", "b", "b"])
    let bag2 = Bag(["a", "a", "b", "c"])
    
    let intersection = bag1.intersection(bag2)
    
    #expect(intersection.count(of: "a") == 2)  // min(3, 2)
    #expect(intersection.count(of: "b") == 1)  // min(2, 1)
    #expect(intersection.count(of: "c") == 0)  // not in bag1
  }
  
  @Test("Subtracting")
  func testSubtracting() {
    let bag1 = Bag(["a", "a", "a", "b", "b"])
    let bag2 = Bag(["a", "b", "b", "b"])
    
    let result = bag1.subtracting(bag2)
    
    #expect(result.count(of: "a") == 2)  // 3 - 1
    #expect(result.count(of: "b") == 0)  // 2 - 3 = 0
  }
  
  // MARK: - Copy-on-Write
  
  @Test("Copy-on-Write semantics")
  func testCopyOnWrite() {
    var original: Bag = ["a", "a", "b"]
    let copy = original
    
    original.insert("c")
    
    #expect(original.count(of: "c") == 1)
    #expect(copy.count(of: "c") == 0)
    #expect(original.totalCount == 4)
    #expect(copy.totalCount == 3)
  }
  
  // MARK: - Sequence Conformance
  
  @Test("Iteration includes duplicates")
  func testIteration() {
    let bag = Bag(["a", "a", "b"])
    
    var collected: [String] = []
    for element in bag {
      collected.append(element)
    }
    
    #expect(collected.count == 3)
    #expect(collected.filter { $0 == "a" }.count == 2)
    #expect(collected.filter { $0 == "b" }.count == 1)
  }
  
  // MARK: - Equatable
  
  @Test("Equality")
  func testEquatable() {
    let bag1 = Bag(["a", "a", "b"])
    let bag2 = Bag(["a", "b", "a"])
    let bag3 = Bag(["a", "b"])
    
    #expect(bag1 == bag2)
    #expect(bag1 != bag3)
  }
  
  // MARK: - Hashable
  
  @Test("Hashable conformance")
  func testHashable() {
    let bag1 = Bag(["a", "a", "b"])
    let bag2 = Bag(["a", "b", "a"])
    
    var set = Set<Bag<String>>()
    set.insert(bag1)
    
    #expect(set.contains(bag2))
  }
  
  // MARK: - Countable Protocol
  
  @Test("Countable conformance")
  func testCountable() {
    let bag: Bag = ["a", "a", "b"]
    
    #expect(bag.count == 3)
    #expect(bag.count == bag.totalCount)
  }
  
  // MARK: - Edge Cases
  
  @Test("Word frequency counting")
  func testWordFrequency() {
    let text = "the quick brown fox jumps over the lazy dog under the fox"
    let words = text.split(separator: " ").map(String.init)
    let bag = Bag(words)
    
    #expect(bag.count(of: "the") == 3)
    #expect(bag.count(of: "fox") == 2)
    #expect(bag.count(of: "quick") == 1)
    #expect(bag.uniqueCount == 9)
    #expect(bag.totalCount == 12)
  }
  
  @Test("Dictionary literal with duplicate keys sums counts")
  func testDictionaryLiteralDuplicateKeys() {
      let bag: Bag<String> = ["a": 1, "a": 2, "b": 3]
      
      #expect(bag.count(of: "a") == 3)
      #expect(bag.count(of: "b") == 3)
      #expect(bag.uniqueCount == 2)
      #expect(bag.totalCount == 6)
  }
}

@Test("Dictionary literal basic usage")
func testDictionaryLiteralBasic() {
    let bag: Bag<String> = ["apple": 3, "banana": 2]
    
    #expect(bag.count(of: "apple") == 3)
    #expect(bag.count(of: "banana") == 2)
    #expect(bag.uniqueCount == 2)
    #expect(bag.totalCount == 5)
}

@Test("Dictionary literal single element")
func testDictionaryLiteralSingleElement() {
    let bag: Bag<String> = ["only": 5]
    
    #expect(bag.count(of: "only") == 5)
    #expect(bag.uniqueCount == 1)
    #expect(bag.totalCount == 5)
}

@Test("Dictionary literal empty")
func testDictionaryLiteralEmpty() {
    let bag: Bag<String> = [:]
    
    #expect(bag.isEmpty)
    #expect(bag.uniqueCount == 0)
    #expect(bag.totalCount == 0)
}

@Test("Dictionary literal with count of 1")
func testDictionaryLiteralCountOfOne() {
    let bag: Bag<String> = ["a": 1, "b": 1, "c": 1]
    
    #expect(bag.count(of: "a") == 1)
    #expect(bag.count(of: "b") == 1)
    #expect(bag.count(of: "c") == 1)
    #expect(bag.uniqueCount == 3)
    #expect(bag.totalCount == 3)
}

@Test("Count validation rejects zero and negative")
func testCountValidation() {
    #expect(Bag<String>.validateCount(1) == true)
    #expect(Bag<String>.validateCount(0) == false)
    #expect(Bag<String>.validateCount(-5) == false)
}
