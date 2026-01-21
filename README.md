# DataStructuresKit

🌐 Language: [Deutsch](README.de.md) | English | [Español](README.es.md) | [Français](README.fr.md)

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A comprehensive, production-ready collection of data structures for Swift, filling the gaps in the standard library with high-performance, well-documented implementations.

## Features

- 🚀 **High Performance**: All operations meet or exceed documented complexity guarantees
- 📖 **Fully Documented**: DocC-compatible documentation with examples
- 🧪 **Thoroughly Tested**: Comprehensive test suite using Swift Testing
- 🔒 **Type Safe**: Generic implementations with full protocol conformances
- 📦 **Zero Dependencies**: Pure Swift implementation (except standard library)
- 🧵 **Sendable Ready**: Proper concurrency annotations for modern Swift

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hoseiocean/DataStructuresKit.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL:
```
```
https://github.com/hoseiocean/DataStructuresKit.git

## Data Structures

### Linear Structures

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`Stack<T>`](#stack) | LIFO collection | push O(1), pop O(1) |
| [`Queue<T>`](#queue) | FIFO collection (circular buffer) | enqueue O(1), dequeue O(1) |
| [`Deque<T>`](#deque) | Double-ended queue | pushFront/Back O(1), popFront/Back O(1) |
| [`LinkedList<T>`](#linkedlist) | Doubly-linked list | insert O(1), remove O(1) |

### Collections

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`Bag<T>`](#bag) | Multiset (counts duplicates) | insert O(1), count(of:) O(1) |

### Trees

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`BinarySearchTree<T>`](#binarysearchtree) | BST with O(log n) average | insert, search, remove |
| [`AVLTree<T>`](#avltree) | Self-balancing BST | insert O(log n) guaranteed |
| [`Trie`](#trie) | Prefix tree for strings | insert O(m), prefix search O(m) |

### Heaps & Priority Queues

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`Heap<T>`](#heap) | Binary heap (min/max) | insert O(log n), extract O(log n) |
| [`PriorityQueue<T>`](#priorityqueue) | Priority queue wrapper | insert O(log n), extractTop O(log n) |

### Graphs

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`Graph<T>`](#graph) | Adjacency list graph | BFS, DFS, Dijkstra O(V+E) |

### Caches

| Structure | Description | Key Operations |
|-----------|-------------|----------------|
| [`LRUCache<K,V>`](#lrucache) | Least Recently Used cache | get O(1), set O(1) |

## Usage Examples

### Stack

```swift
import DataStructuresKit

var stack = Stack<Int>()
stack.push(1)
stack.push(2)
stack.push(3)

print(stack.peek)  // Optional(3)
print(stack.pop()) // Optional(3)
print(stack.count) // 2

// Array literal initialization
let stack2: Stack = ["a", "b", "c"]

// Iteration (LIFO order)
for item in stack2 {
    print(item) // c, b, a
}
```

### Queue

```swift
var queue = Queue<String>()
queue.enqueue("first")
queue.enqueue("second")
queue.enqueue("third")

print(queue.front) // Optional("first")
print(queue.dequeue()) // Optional("first")

// Circular buffer ensures O(1) dequeue
```

### Deque

```swift
var deque = Deque<Int>()
deque.pushBack(2)
deque.pushFront(1)
deque.pushBack(3)
// deque: [1, 2, 3]

print(deque.popFront()) // Optional(1)
print(deque.popBack())  // Optional(3)

// Random access
print(deque[0]) // 2
```

### LinkedList

```swift
let list = LinkedList<String>()
let nodeA = list.append("A")
let nodeB = list.append("B")
list.append("C")

list.insert("A.5", after: nodeA)
list.remove(nodeB)

for item in list {
    print(item) // A, A.5, C
}
```

### Bag

```swift
// Count word frequencies
let text = "the quick brown fox jumps over the lazy dog the fox"
let words = text.split(separator: " ").map(String.init)
var bag = Bag(words)

print(bag.count(of: "the"))  // 3
print(bag.count(of: "fox"))  // 2
print(bag.uniqueCount)       // 9
print(bag.totalCount)        // 11

// Get most common words
let top3 = bag.mostCommon(3)
// [("the", 3), ("fox", 2), ("quick", 1)]

// Inventory system
var inventory: Bag = ["sword": 2, "potion": 5, "shield": 1]
inventory.insert("potion", count: 3)
print(inventory.count(of: "potion")) // 8

inventory.remove("potion", count: 2)
print(inventory.count(of: "potion")) // 6
```

### BinarySearchTree

```swift
var bst = BinarySearchTree<Int>()
bst.insert(5)
bst.insert(3)
bst.insert(7)
bst.insert(1)
bst.insert(9)

print(bst.contains(3)) // true
print(bst.min)         // Optional(1)
print(bst.max)         // Optional(9)
print(bst.sorted)      // [1, 3, 5, 7, 9]
```

### AVLTree

```swift
var tree = AVLTree<Int>()

// Even sorted insertion maintains O(log n) height
for i in 1...1000 {
    tree.insert(i)
}

print(tree.height) // ~10 (vs 999 for unbalanced BST)
```

### Trie

```swift
var trie = Trie()
trie.insert("apple")
trie.insert("app")
trie.insert("application")
trie.insert("banana")

print(trie.contains("app"))     // true
print(trie.hasPrefix("appl"))   // true
print(trie.words(withPrefix: "app")) // ["app", "apple", "application"]

// Autocomplete support
let suggestions = trie.words(withPrefix: userInput)
```

### Heap

```swift
// Min heap (smallest first)
var minHeap = Heap<Int>.minHeap()
minHeap.insert(5)
minHeap.insert(3)
minHeap.insert(7)

print(minHeap.extract()) // Optional(3)
print(minHeap.extract()) // Optional(5)

// Max heap (largest first)
var maxHeap = Heap<Int>.maxHeap()

// Build from sequence in O(n)
let heap = Heap.minHeap([5, 3, 7, 1, 9])
```

### PriorityQueue

```swift
var tasks = PriorityQueue<Int>()
tasks.insert(priority: 5)
tasks.insert(priority: 1)
tasks.insert(priority: 3)

while let next = tasks.extractTop() {
    print(next) // 1, 3, 5
}

// Max priority queue
var scores = PriorityQueue<Int>.maxPriorityQueue()
```

### Graph

```swift
let graph = Graph<String>(edgeType: .undirected)

graph.addEdge(from: "A", to: "B", weight: 1)
graph.addEdge(from: "B", to: "C", weight: 2)
graph.addEdge(from: "A", to: "C", weight: 5)

// BFS traversal
graph.bfs(from: "A") { vertex in
    print("Visited: \(vertex)")
    return true // continue
}

// Shortest path (unweighted)
let path = graph.shortestPath(from: "A", to: "C")
print(path) // ["A", "B", "C"]

// Dijkstra's algorithm (weighted)
let distances = graph.dijkstra(from: "A")
print(distances["C"]?.distance) // 3.0 (via B)
```

### LRUCache

```swift
let cache = LRUCache<String, Data>(capacity: 100)

// Store
cache.set("image_123", value: imageData)

// Retrieve (marks as recently used)
if let data = cache.get("image_123") {
    display(data)
}

// Subscript syntax
cache["key"] = value
let retrieved = cache["key"]

// Auto-eviction when capacity reached
```

## Design Principles

This library follows strict design principles documented in Architecture Decision Records (ADRs):

- **ADR-001: Copy Semantics** - Value types use Copy-on-Write; reference types for complex structures
- **ADR-002: ABI Stability** - Source compatibility guaranteed; binary compatibility not promised
- **ADR-003: Performance Audit** - All complexities verified with benchmarks

### Protocol Conformances

All applicable types conform to:
- `Sequence` / `Collection` / `RandomAccessCollection`
- `ExpressibleByArrayLiteral`
- `Equatable` / `Hashable` (when Element conforms)
- `Sendable` (when Element is Sendable)
- `CustomStringConvertible`

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+ / visionOS 1+

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) and the ADR documents in `/Documentation/ADR/` before contributing to understand our development process and design decisions.

## License

MIT License - see [LICENSE](LICENSE) for details.
