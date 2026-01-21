// MARK: - DataStructuresKit
//
// A comprehensive, professional-grade collection of data structures for Swift.
//
// Copyright © 2025 - MIT License
//
// ## Overview
//
// DataStructuresKit provides high-performance implementations of common
// data structures missing from the Swift Standard Library:
//
// ### Linear Structures
// - `Stack` - LIFO with O(1) push/pop
// - `Queue` - FIFO with O(1) enqueue/dequeue (circular buffer)
// - `Deque` - Double-ended with O(1) operations at both ends
// - `LinkedList` - Doubly-linked with O(1) insert/remove
//
// ### Trees
// - `BinarySearchTree` - O(log n) average operations
// - `AVLTree` - Self-balancing with O(log n) guaranteed
// - `Trie` - Prefix tree for string operations
//
// ### Heaps
// - `Heap` - Binary heap (min or max)
// - `PriorityQueue` - Convenience wrapper around Heap
//
// ### Graphs
// - `Graph` - Adjacency list with BFS, DFS, Dijkstra
//
// ### Caches
// - `LRUCache` - Least Recently Used with O(1) operations
//
// ## Design Principles
//
// - **Performance First**: All complexities documented and verified
// - **Copy-on-Write**: Value types use CoW for efficient copying
// - **Protocol-Oriented**: Shared protocols for common behavior
// - **Swift Conventions**: Follows Swift API Design Guidelines
// - **Fully Tested**: Comprehensive test suite with performance tests
//
// ## ADR Compliance
//
// This library follows Architecture Decision Records documented in
// `/Documentation/ADR/`:
//
// - ADR-001: Copy Semantics Strategy
// - ADR-002: ABI Stability Rules  
// - ADR-003: Performance Audit Framework
//
// ## Quick Start
//
// ```swift
// import DataStructuresKit
//
// // Stack
// var stack = Stack<Int>()
// stack.push(1)
// stack.push(2)
// print(stack.pop()) // Optional(2)
//
// // Queue
// var queue: Queue = [1, 2, 3]
// print(queue.dequeue()) // Optional(1)
//
// // Priority Queue
// var pq = PriorityQueue<Int>()
// pq.insert(5)
// pq.insert(1)
// pq.insert(3)
// print(pq.extractTop()) // Optional(1)
//
// // Graph
// let graph = Graph<String>()
// graph.addEdge(from: "A", to: "B")
// graph.addEdge(from: "B", to: "C")
// print(graph.shortestPath(from: "A", to: "C")) // ["A", "B", "C"]
// ```

// MARK: - Public Exports

// All types are automatically available when importing DataStructuresKit
// due to being in the same module.

// MARK: - Version

/// The current version of DataStructuresKit.
public enum DataStructuresKit {
  /// The semantic version string.
  public static let version = "1.0.0"
  
  /// The build date.
  public static let buildDate = "2025-01-19"
}

// MARK: - Type Aliases for Convenience

/// A min-priority queue where smallest elements have highest priority.
public typealias MinPriorityQueue<T: Comparable> = PriorityQueue<T>

/// A max-priority queue where largest elements have highest priority.
/// 
/// Note: Create with `PriorityQueue.maxPriorityQueue()` for proper ordering.
public typealias MaxPriorityQueue<T: Comparable> = PriorityQueue<T>
