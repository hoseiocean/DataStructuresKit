import Testing
@testable import DataStructuresKit

@Suite("Queue Tests")
struct QueueTests {
    
    // MARK: - Initialization
    
    @Test("Empty queue initialization")
    func testEmptyInit() {
        let queue = Queue<Int>()
        
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.front == nil)
        #expect(queue.back == nil)
    }
    
    @Test("Initialization from sequence")
    func testSequenceInit() {
        let queue = Queue([1, 2, 3, 4, 5])
        
        #expect(queue.count == 5)
        #expect(queue.front == 1)
        #expect(queue.back == 5)
    }
    
    @Test("Initialization from array literal")
    func testArrayLiteralInit() {
        let queue: Queue<String> = ["a", "b", "c"]
        
        #expect(queue.count == 3)
        #expect(queue.front == "a")
    }
    
    // MARK: - Enqueue Operations
    
    @Test("Enqueue single element")
    func testEnqueueSingle() {
        var queue = Queue<Int>()
        queue.enqueue(42)
        
        #expect(queue.count == 1)
        #expect(queue.front == 42)
        #expect(queue.back == 42)
    }
    
    @Test("Enqueue multiple elements")
    func testEnqueueMultiple() {
        var queue = Queue<Int>()
        
        for i in 1...100 {
            queue.enqueue(i)
            #expect(queue.front == 1)
            #expect(queue.back == i)
            #expect(queue.count == i)
        }
    }
    
    // MARK: - Dequeue Operations
    
    @Test("Dequeue returns elements in FIFO order")
    func testDequeue() {
        var queue: Queue = [1, 2, 3]
        
        #expect(queue.dequeue() == 1)
        #expect(queue.dequeue() == 2)
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == nil)
    }
    
    @Test("Dequeue from empty queue returns nil")
    func testDequeueEmpty() {
        var queue = Queue<Int>()
        
        #expect(queue.dequeue() == nil)
        #expect(queue.isEmpty)
    }
    
    // MARK: - Circular Buffer Behavior
    
    @Test("Circular buffer wraps correctly")
    func testCircularBuffer() {
        var queue = Queue<Int>(minimumCapacity: 4)
        
        // Fill partially
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        
        // Remove some
        _ = queue.dequeue() // 1
        _ = queue.dequeue() // 2
        
        // Add more (should wrap around)
        queue.enqueue(4)
        queue.enqueue(5)
        queue.enqueue(6)
        
        // Verify order is maintained
        #expect(queue.dequeue() == 3)
        #expect(queue.dequeue() == 4)
        #expect(queue.dequeue() == 5)
        #expect(queue.dequeue() == 6)
    }
    
    // MARK: - Copy-on-Write
    
    @Test("Copy-on-Write semantics")
    func testCopyOnWrite() {
      let original: Queue = [1, 2, 3]
        var copy = original
        
        copy.enqueue(4)
        
        #expect(original.count == 3)
        #expect(copy.count == 4)
    }
    
    @Test("Copy-on-Write with dequeue")
    func testCopyOnWriteDequeue() {
      let original: Queue = [1, 2, 3]
        var copy = original
        
        _ = copy.dequeue()
        
        #expect(original.count == 3)
        #expect(original.front == 1)
        #expect(copy.count == 2)
        #expect(copy.front == 2)
    }
    
    // MARK: - Sequence Conformance
    
    @Test("Iteration returns elements in FIFO order")
    func testIteration() {
        let queue: Queue = [1, 2, 3, 4, 5]
        let result = Array(queue)
        
        #expect(result == [1, 2, 3, 4, 5])
    }
    
    // MARK: - Equatable
    
    @Test("Equal queues")
    func testEquatable() {
        let queue1: Queue = [1, 2, 3]
        let queue2: Queue = [1, 2, 3]
        let queue3: Queue = [1, 2, 4]
        
        #expect(queue1 == queue2)
        #expect(queue1 != queue3)
    }
    
    // MARK: - Resize Behavior
    
    @Test("Queue grows when full")
    func testGrow() {
        var queue = Queue<Int>(minimumCapacity: 2)
        
        for i in 1...100 {
            queue.enqueue(i)
        }
        
        #expect(queue.count == 100)
        #expect(queue.front == 1)
        
        // Verify all elements are present in order
        for i in 1...100 {
            #expect(queue.dequeue() == i)
        }
    }
    
    @Test("Queue shrinks when mostly empty")
    func testShrink() {
        var queue = Queue<Int>()
        
        // Add many elements
        for i in 1...1000 {
            queue.enqueue(i)
        }
        
        let fullCapacity = queue.capacity
        
        // Remove most elements
        for _ in 1...990 {
            _ = queue.dequeue()
        }
        
        // Capacity should have shrunk
        #expect(queue.capacity < fullCapacity)
        #expect(queue.count == 10)
    }
    
    // MARK: - RemoveAll
    
    @Test("RemoveAll clears the queue")
    func testRemoveAll() {
        var queue: Queue = [1, 2, 3, 4, 5]
        queue.removeAll()
        
        #expect(queue.isEmpty)
        #expect(queue.count == 0)
        #expect(queue.front == nil)
    }
}
