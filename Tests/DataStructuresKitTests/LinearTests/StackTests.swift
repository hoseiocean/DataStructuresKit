import Testing
@testable import DataStructuresKit

@Suite("Stack Tests")
struct StackTests {
    
    // MARK: - Initialization
    
    @Test("Empty stack initialization")
    func testEmptyInit() {
        let stack = Stack<Int>()
        
        #expect(stack.isEmpty)
        #expect(stack.count == 0)
        #expect(stack.peek == nil)
    }
    
    @Test("Initialization from sequence")
    func testSequenceInit() {
        let stack = Stack([1, 2, 3, 4, 5])
        
        #expect(stack.count == 5)
        #expect(stack.peek == 5)
    }
    
    @Test("Initialization from array literal")
    func testArrayLiteralInit() {
        let stack: Stack<String> = ["a", "b", "c"]
        
        #expect(stack.count == 3)
        #expect(stack.peek == "c")
    }
    
    // MARK: - Push Operations
    
    @Test("Push single element")
    func testPushSingle() {
        var stack = Stack<Int>()
        stack.push(42)
        
        #expect(stack.count == 1)
        #expect(stack.peek == 42)
        #expect(!stack.isEmpty)
    }
    
    @Test("Push multiple elements")
    func testPushMultiple() {
        var stack = Stack<Int>()
        
        for i in 1...100 {
            stack.push(i)
            #expect(stack.peek == i)
            #expect(stack.count == i)
        }
    }
    
    // MARK: - Pop Operations
    
    @Test("Pop from non-empty stack")
    func testPop() {
        var stack: Stack = [1, 2, 3]
        
        #expect(stack.pop() == 3)
        #expect(stack.pop() == 2)
        #expect(stack.pop() == 1)
        #expect(stack.pop() == nil)
    }
    
    @Test("Pop from empty stack returns nil")
    func testPopEmpty() {
        var stack = Stack<Int>()
        
        #expect(stack.pop() == nil)
        #expect(stack.isEmpty)
    }
    
    // MARK: - Peek Operations
    
    @Test("Peek does not remove element")
    func testPeekNonDestructive() {
        let stack: Stack = [1, 2, 3]
        
        #expect(stack.peek == 3)
        #expect(stack.peek == 3)
        #expect(stack.count == 3)
    }
    
    // MARK: - Copy-on-Write
    
    @Test("Copy-on-Write semantics")
    func testCopyOnWrite() {
      let original: Stack = [1, 2, 3]
        var copy = original
        
        copy.push(4)
        
        #expect(original.count == 3)
        #expect(copy.count == 4)
        #expect(original.peek == 3)
        #expect(copy.peek == 4)
    }
    
    @Test("Copy-on-Write with pop")
    func testCopyOnWritePop() {
      let original: Stack = [1, 2, 3]
        var copy = original
        
        _ = copy.pop()
        
        #expect(original.count == 3)
        #expect(copy.count == 2)
    }
    
    // MARK: - Sequence Conformance
    
    @Test("Iteration returns elements in LIFO order")
    func testIteration() {
        let stack: Stack = [1, 2, 3, 4, 5]
        let result = Array(stack)
        
        #expect(result == [5, 4, 3, 2, 1])
    }
    
    // MARK: - Equatable
    
    @Test("Equal stacks")
    func testEquatable() {
        let stack1: Stack = [1, 2, 3]
        let stack2: Stack = [1, 2, 3]
        let stack3: Stack = [1, 2, 4]
        
        #expect(stack1 == stack2)
        #expect(stack1 != stack3)
    }
    
    // MARK: - Hashable
    
    @Test("Hashable conformance")
    func testHashable() {
        let stack1: Stack = [1, 2, 3]
        let stack2: Stack = [1, 2, 3]
        
        var set = Set<Stack<Int>>()
        set.insert(stack1)
        
        #expect(set.contains(stack2))
    }
    
    // MARK: - Additional Operations
    
    @Test("RemoveAll clears the stack")
    func testRemoveAll() {
        var stack: Stack = [1, 2, 3, 4, 5]
        stack.removeAll()
        
        #expect(stack.isEmpty)
        #expect(stack.count == 0)
    }
    
    @Test("Reserve capacity")
    func testReserveCapacity() {
        var stack = Stack<Int>()
        stack.reserveCapacity(1000)
        
        #expect(stack.capacity >= 1000)
    }
}
