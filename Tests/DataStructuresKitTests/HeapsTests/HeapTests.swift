import Testing
@testable import DataStructuresKit

@Suite("Heap Tests")
struct HeapTests {
  
  // MARK: - Min Heap
  
  @Test("Empty min heap")
  func testEmptyMinHeap() {
    let heap = Heap<Int>.minHeap()
    
    #expect(heap.isEmpty)
    #expect(heap.count == 0)
    #expect(heap.peek == nil)
  }
  
  @Test("Min heap insert and extract")
  func testMinHeapBasic() {
    var heap = Heap<Int>.minHeap()
    
    heap.insert(5)
    heap.insert(3)
    heap.insert(7)
    heap.insert(1)
    heap.insert(9)
    
    #expect(heap.count == 5)
    #expect(heap.peek == 1)
    
    #expect(heap.extract() == 1)
    #expect(heap.extract() == 3)
    #expect(heap.extract() == 5)
    #expect(heap.extract() == 7)
    #expect(heap.extract() == 9)
    #expect(heap.extract() == nil)
  }
  
  @Test("Min heap from sequence (Floyd's algorithm)")
  func testMinHeapFromSequence() {
    let heap = Heap.minHeap([5, 3, 7, 1, 9, 2, 8])
    
    #expect(heap.peek == 1)
    #expect(heap.count == 7)
  }
  
  // MARK: - Max Heap
  
  @Test("Max heap insert and extract")
  func testMaxHeapBasic() {
    var heap = Heap<Int>.maxHeap()
    
    heap.insert(5)
    heap.insert(3)
    heap.insert(7)
    heap.insert(1)
    heap.insert(9)
    
    #expect(heap.peek == 9)
    
    #expect(heap.extract() == 9)
    #expect(heap.extract() == 7)
    #expect(heap.extract() == 5)
    #expect(heap.extract() == 3)
    #expect(heap.extract() == 1)
  }
  
  // MARK: - Custom Comparator
  
  @Test("Custom comparator heap")
  func testCustomComparator() {
    // Sort by string length
    var heap = Heap<String>(comparator: { $0.count < $1.count })
    
    heap.insert("aaa")
    heap.insert("a")
    heap.insert("aa")
    
    #expect(heap.extract() == "a")
    #expect(heap.extract() == "aa")
    #expect(heap.extract() == "aaa")
  }
  
  // MARK: - Copy-on-Write
  
  @Test("Copy-on-Write semantics")
  func testCopyOnWrite() {
    var original = Heap.minHeap([3, 1, 2])
    let copy = original
    
    _ = original.extract()
    
    #expect(original.count == 2)
    #expect(copy.count == 3)
    #expect(copy.peek == 1)
  }
  
  // MARK: - Iteration
  
  @Test("Iteration extracts in priority order")
  func testIteration() {
    let heap = Heap.minHeap([5, 3, 7, 1, 9])
    let result = Array(heap)
    
    #expect(result == [1, 3, 5, 7, 9])
  }
  
  // MARK: - Edge Cases
  
  @Test("Single element heap")
  func testSingleElement() {
    var heap = Heap<Int>.minHeap()
    heap.insert(42)
    
    #expect(heap.peek == 42)
    #expect(heap.extract() == 42)
    #expect(heap.isEmpty)
  }
  
  @Test("Duplicate elements")
  func testDuplicates() {
    var heap = Heap<Int>.minHeap()
    heap.insert(5)
    heap.insert(5)
    heap.insert(5)
    
    #expect(heap.count == 3)
    #expect(heap.extract() == 5)
    #expect(heap.extract() == 5)
    #expect(heap.extract() == 5)
  }
}

@Suite("PriorityQueue Tests")
struct PriorityQueueTests {
  
  // MARK: - Min Priority Queue
  
  @Test("Min priority queue (default)")
  func testMinPriorityQueue() {
    var pq = PriorityQueue<Int>()
    
    pq.insert(5)
    pq.insert(1)
    pq.insert(3)
    
    #expect(pq.top == 1)
    #expect(pq.extractTop() == 1)
    #expect(pq.extractTop() == 3)
    #expect(pq.extractTop() == 5)
  }
  
  // MARK: - Max Priority Queue
  
  @Test("Max priority queue")
  func testMaxPriorityQueue() {
    var pq = PriorityQueue<Int>.maxPriorityQueue()
    
    pq.insert(5)
    pq.insert(1)
    pq.insert(3)
    
    #expect(pq.top == 5)
    #expect(pq.extractTop() == 5)
    #expect(pq.extractTop() == 3)
    #expect(pq.extractTop() == 1)
  }
  
  // MARK: - Array Literal
  
  @Test("Array literal initialization")
  func testArrayLiteral() {
    let pq: PriorityQueue = [5, 1, 3, 2, 4]
    
    #expect(pq.count == 5)
    #expect(pq.top == 1)
  }
  
  // MARK: - Iteration
  
  @Test("Iteration in priority order")
  func testIteration() {
    let pq: PriorityQueue = [5, 1, 3, 2, 4]
    let result = Array(pq)
    
    #expect(result == [1, 2, 3, 4, 5])
  }
}
