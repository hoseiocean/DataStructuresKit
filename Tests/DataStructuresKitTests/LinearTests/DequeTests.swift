import Testing
@testable import DataStructuresKit

@Suite("Deque Tests")
struct DequeTests {
    
    // MARK: - Initialization
    
    @Test("Empty deque initialization")
    func testEmptyInit() {
        let deque = Deque<Int>()
        
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
        #expect(deque.front == nil)
        #expect(deque.back == nil)
    }
    
    @Test("Initialization from sequence")
    func testSequenceInit() {
        let deque = Deque([1, 2, 3, 4, 5])
        
        #expect(deque.count == 5)
        #expect(deque.front == 1)
        #expect(deque.back == 5)
    }
    
    // MARK: - Push Operations
    
    @Test("Push front")
    func testPushFront() {
        var deque = Deque<Int>()
        
        deque.pushFront(3)
        deque.pushFront(2)
        deque.pushFront(1)
        
        #expect(Array(deque) == [1, 2, 3])
    }
    
    @Test("Push back")
    func testPushBack() {
        var deque = Deque<Int>()
        
        deque.pushBack(1)
        deque.pushBack(2)
        deque.pushBack(3)
        
        #expect(Array(deque) == [1, 2, 3])
    }
    
    @Test("Mixed push operations")
    func testMixedPush() {
        var deque = Deque<Int>()
        
        deque.pushBack(2)    // [2]
        deque.pushFront(1)   // [1, 2]
        deque.pushBack(3)    // [1, 2, 3]
        deque.pushFront(0)   // [0, 1, 2, 3]
        
        #expect(Array(deque) == [0, 1, 2, 3])
    }
    
    // MARK: - Pop Operations
    
    @Test("Pop front")
    func testPopFront() {
        var deque: Deque = [1, 2, 3]
        
        #expect(deque.popFront() == 1)
        #expect(deque.popFront() == 2)
        #expect(deque.popFront() == 3)
        #expect(deque.popFront() == nil)
    }
    
    @Test("Pop back")
    func testPopBack() {
        var deque: Deque = [1, 2, 3]
        
        #expect(deque.popBack() == 3)
        #expect(deque.popBack() == 2)
        #expect(deque.popBack() == 1)
        #expect(deque.popBack() == nil)
    }
    
    @Test("Mixed pop operations")
    func testMixedPop() {
        var deque: Deque = [1, 2, 3, 4]
        
        #expect(deque.popFront() == 1)
        #expect(deque.popBack() == 4)
        #expect(deque.popFront() == 2)
        #expect(deque.popBack() == 3)
        #expect(deque.isEmpty)
    }
    
    // MARK: - Random Access
    
    @Test("Subscript access")
    func testSubscript() {
        let deque: Deque = [10, 20, 30, 40, 50]
        
        #expect(deque[0] == 10)
        #expect(deque[2] == 30)
        #expect(deque[4] == 50)
    }
    
    @Test("Subscript mutation")
    func testSubscriptMutation() {
        var deque: Deque = [1, 2, 3]
        
        deque[1] = 42
        
        #expect(deque[1] == 42)
        #expect(Array(deque) == [1, 42, 3])
    }
    
    // MARK: - RandomAccessCollection
    
    @Test("Collection indices")
    func testCollectionIndices() {
        let deque: Deque = [1, 2, 3, 4, 5]
        
        #expect(deque.startIndex == 0)
        #expect(deque.endIndex == 5)
        #expect(deque.index(after: 0) == 1)
        #expect(deque.index(before: 3) == 2)
    }
    
    // MARK: - Copy-on-Write
    
    @Test("Copy-on-Write semantics")
    func testCopyOnWrite() {
      let original: Deque = [1, 2, 3]
        var copy = original
        
        copy.pushBack(4)
        copy.pushFront(0)
        
        #expect(original.count == 3)
        #expect(copy.count == 5)
        #expect(Array(original) == [1, 2, 3])
        #expect(Array(copy) == [0, 1, 2, 3, 4])
    }
    
    // MARK: - Circular Buffer
    
    @Test("Circular buffer wrap around")
    func testCircularWrap() {
        var deque = Deque<Int>(minimumCapacity: 4)
        
        // Fill and partially empty
        deque.pushBack(1)
        deque.pushBack(2)
        deque.pushBack(3)
        _ = deque.popFront()
        _ = deque.popFront()
        
        // Now head is offset, push should wrap
        deque.pushBack(4)
        deque.pushBack(5)
        deque.pushFront(0)
        
        // Verify order is correct
        #expect(Array(deque) == [0, 3, 4, 5])
    }
    
    // MARK: - Equatable
    
    @Test("Equal deques")
    func testEquatable() {
        let deque1: Deque = [1, 2, 3]
        let deque2: Deque = [1, 2, 3]
        let deque3: Deque = [1, 2, 4]
        
        #expect(deque1 == deque2)
        #expect(deque1 != deque3)
    }
    
    // MARK: - Aliases
    
    @Test("Append and prepend aliases")
    func testAliases() {
        var deque = Deque<Int>()
        
        deque.append(2)
        deque.prepend(1)
        deque.append(3)
        
        #expect(deque.removeFirst() == 1)
        #expect(deque.removeLast() == 3)
    }
    
    // MARK: - RemoveAll
    
    @Test("RemoveAll clears the deque")
    func testRemoveAll() {
        var deque: Deque = [1, 2, 3, 4, 5]
        deque.removeAll()
        
        #expect(deque.isEmpty)
        #expect(deque.count == 0)
    }
}
