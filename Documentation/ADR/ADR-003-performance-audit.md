# ADR-003: Performance Audit Framework

## Status
**Accepted** - 2025-01-19

## Context

DataStructuresKit vise les performances maximales. Chaque structure doit être auditée avant intégration pour garantir les complexités annoncées.

## Performance Targets

### Time Complexity Requirements

| Structure | Operation | Target | Acceptable | Unacceptable |
|-----------|-----------|--------|------------|--------------|
| **Stack** | push | O(1)* | O(1)* | O(n) |
| | pop | O(1) | O(1) | O(n) |
| | peek | O(1) | O(1) | - |
| **Queue** | enqueue | O(1)* | O(1)* | O(n) |
| | dequeue | O(1) | O(1) | O(n) |
| **Deque** | pushFront/Back | O(1)* | O(1)* | O(n) |
| | popFront/Back | O(1) | O(1) | O(n) |
| **LinkedList** | prepend/append | O(1) | O(1) | - |
| | insert(after:) | O(1) | O(1) | - |
| | remove(node:) | O(1) | O(1) | - |
| | subscript[i] | O(n) | O(n) | - |
| **BST** | insert | O(log n)† | O(log n)† | - |
| | search | O(log n)† | O(log n)† | - |
| | delete | O(log n)† | O(log n)† | - |
| **AVLTree** | insert | O(log n) | O(log n) | O(n) |
| | search | O(log n) | O(log n) | O(n) |
| | delete | O(log n) | O(log n) | O(n) |
| **Trie** | insert | O(m) | O(m) | - |
| | search | O(m) | O(m) | - |
| | prefix | O(m + k) | O(m + k) | - |
| **Heap** | insert | O(log n) | O(log n) | O(n) |
| | extractMin/Max | O(log n) | O(log n) | O(n) |
| | peek | O(1) | O(1) | - |
| **Graph** | addVertex | O(1) | O(1) | - |
| | addEdge | O(1) | O(1) | - |
| | neighbors | O(1) | O(degree) | O(V) |
| | BFS/DFS | O(V+E) | O(V+E) | - |
| **LRUCache** | get | O(1) | O(1) | O(n) |
| | set | O(1) | O(1) | O(n) |

*Amortized
†Average case, O(n) worst case acceptable for non-balanced BST
m = string length, k = number of results

### Space Complexity Requirements

| Structure | Space | Notes |
|-----------|-------|-------|
| Stack | O(n) | n = number of elements |
| Queue | O(n) | Circular buffer, no wasted space at steady state |
| Deque | O(n) | Growth factor 2x, shrink at 25% capacity |
| LinkedList | O(n) | 2 pointers overhead per node |
| BST/AVL | O(n) | 2-3 pointers per node |
| Trie | O(ALPHABET × m × n) | Optimize with compressed trie if needed |
| Heap | O(n) | Array-based, minimal overhead |
| Graph | O(V + E) | Adjacency list |
| LRUCache | O(capacity) | Fixed size |

## Audit Protocol

### Phase 1: Static Analysis
```bash
# Vérifier absence d'allocations dans hot paths
swift build -Xswiftc -Xfrontend -Xswiftc -warn-long-function-bodies=100
```

### Phase 2: Complexity Verification Tests

Chaque structure DOIT avoir des tests de scaling :

```swift
@Test("Stack push is O(1) amortized", .tags(.performance))
func testStackPushComplexity() {
    // Mesurer temps pour N opérations
    let sizes = [1_000, 10_000, 100_000, 1_000_000]
    var times: [Double] = []
    
    for size in sizes {
        var stack = Stack<Int>()
        let start = ContinuousClock.now
        for i in 0..<size {
            stack.push(i)
        }
        let elapsed = start.duration(to: .now)
        times.append(elapsed.components.seconds + Double(elapsed.components.attoseconds) * 1e-18)
    }
    
    // Vérifier croissance linéaire (O(n) total = O(1) par opération)
    // Ratio temps devrait être ~10x quand size est 10x
    for i in 1..<sizes.count {
        let ratio = times[i] / times[i-1]
        let sizeRatio = Double(sizes[i]) / Double(sizes[i-1])
        // Tolérance de 3x pour variations système
        #expect(ratio < sizeRatio * 3, "Push scaling exceeds O(1) amortized")
    }
}
```

### Phase 3: Memory Profiling

```swift
@Test("Stack has no memory leaks", .tags(.memory))
func testStackMemoryManagement() {
    weak var weakRef: AnyObject?
    
    autoreleasepool {
        var stack = Stack<NSObject>()
        let obj = NSObject()
        weakRef = obj
        stack.push(obj)
        stack.pop()
    }
    
    #expect(weakRef == nil, "Memory leak detected")
}
```

### Phase 4: Copy-on-Write Verification

```swift
@Test("Stack implements CoW correctly")
func testStackCopyOnWrite() {
    var original = Stack<Int>()
    original.push(1)
    original.push(2)
    
    // Copie ne doit pas allouer
    var copy = original
    #expect(copy.count == 2)
    
    // Mutation de copy ne doit pas affecter original
    copy.push(3)
    #expect(original.count == 2)
    #expect(copy.count == 3)
}
```

## Optimization Guidelines

### G1: Avoid ARC Traffic in Hot Paths
```swift
// ❌ Mauvais - incr/decr refcount à chaque appel
func process(_ element: Element) {
    // element est retenu
}

// ✅ Bon - borrowing évite le traffic ARC
func process(_ element: borrowing Element) {
    // element emprunté, pas de refcount
}
```

### G2: Use `@inlinable` Judiciously
```swift
// ✅ Fonction triviale, bénéficie de l'inlining
@inlinable
public var isEmpty: Bool { storage.count == 0 }

// ❌ Ne pas inliner les fonctions complexes
// (augmente taille binaire, empêche optimisations futures)
public mutating func rebalance() { /* complex */ }
```

### G3: Prefer `withUnsafeBufferPointer` for Bulk Operations
```swift
// ✅ Accès direct au buffer sans bounds checking
public func forEach(_ body: (Element) throws -> Void) rethrows {
    try storage.withUnsafeBufferPointer { buffer in
        for element in buffer {
            try body(element)
        }
    }
}
```

### G4: Reserve Capacity When Size is Known
```swift
// ✅ Évite les réallocations
public init<S: Sequence>(_ elements: S) where S.Element == Element {
    if let count = elements.underestimatedCount, count > 0 {
        storage = Storage(minimumCapacity: count)
    }
    for element in elements {
        push(element)
    }
}
```

## Benchmark Suite Requirements

Chaque PR modifiant une structure DOIT inclure :

1. **Micro-benchmarks** : Opérations individuelles
2. **Scaling tests** : Vérification complexité
3. **Memory tests** : Pas de leaks, CoW correct
4. **Comparison baseline** : vs Array/stdlib si applicable

## Compliance Checklist

Avant merge :
- [ ] Toutes les complexités documentées
- [ ] Tests de scaling passent
- [ ] Pas de régression vs baseline
- [ ] Memory leaks vérifiés
- [ ] CoW testé (si applicable)
- [ ] Pas d'allocations dans hot paths (vérifié via Instruments si doute)
