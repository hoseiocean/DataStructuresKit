# DataStructuresKit

🌐 Sprache: Deutsch | [English](README.md) | [Español](README.es.md) | [Français](README.fr.md)

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Eine umfassende, produktionsreife Sammlung von Datenstrukturen für Swift, die die Lücken in der Standardbibliothek mit hochperformanten, gut dokumentierten Implementierungen schließt.

## Funktionen

- 🚀 **Hohe Leistung**: Alle Operationen erfüllen oder übertreffen die dokumentierten Komplexitätsgarantien
- 📖 **Vollständig dokumentiert**: DocC-kompatible Dokumentation mit Beispielen
- 🧪 **Gründlich getestet**: Umfassende Testsuite mit Swift Testing
- 🔒 **Typsicher**: Generische Implementierungen mit vollständigen Protokollkonformitäten
- 📦 **Keine Abhängigkeiten**: Reine Swift-Implementierung (außer Standardbibliothek)
- 🧵 **Sendable-bereit**: Korrekte Nebenläufigkeitsannotationen für modernes Swift

## Installation

### Swift Package Manager

Fügen Sie zu Ihrer `Package.swift` hinzu:

```swift
dependencies: [
    .package(url: "https://github.com/hoseiocean/DataStructuresKit.git", from: "1.0.0")
]
```

Oder in Xcode: Datei → Paketabhängigkeiten hinzufügen → Repository-URL eingeben :
```
```
https://github.com/hoseiocean/DataStructuresKit.git

## Datenstrukturen

### Lineare Strukturen

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`Stack<T>`](#stack) | LIFO-Sammlung | push O(1), pop O(1) |
| [`Queue<T>`](#queue) | FIFO-Sammlung (Ringpuffer) | enqueue O(1), dequeue O(1) |
| [`Deque<T>`](#deque) | Doppelseitige Warteschlange | pushFront/Back O(1), popFront/Back O(1) |
| [`LinkedList<T>`](#linkedlist) | Doppelt verkettete Liste | insert O(1), remove O(1) |

### Sammlungen

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`Bag<T>`](#bag) | Multimenge (zählt Duplikate) | insert O(1), count(of:) O(1) |

### Bäume

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`BinarySearchTree<T>`](#binarysearchtree) | BST mit O(log n) im Durchschnitt | insert, search, remove |
| [`AVLTree<T>`](#avltree) | Selbstbalancierender BST | insert O(log n) garantiert |
| [`Trie`](#trie) | Präfixbaum für Strings | insert O(m), Präfixsuche O(m) |

### Heaps und Prioritätswarteschlangen

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`Heap<T>`](#heap) | Binärer Heap (min/max) | insert O(log n), extract O(log n) |
| [`PriorityQueue<T>`](#priorityqueue) | Prioritätswarteschlangen-Wrapper | insert O(log n), extractTop O(log n) |

### Graphen

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`Graph<T>`](#graph) | Adjazenzlisten-Graph | BFS, DFS, Dijkstra O(V+E) |

### Caches

| Struktur | Beschreibung | Hauptoperationen |
|----------|--------------|------------------|
| [`LRUCache<K,V>`](#lrucache) | Least Recently Used Cache | get O(1), set O(1) |

## Verwendungsbeispiele

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

// Array-Literal-Initialisierung
let stack2: Stack = ["a", "b", "c"]

// Iteration (LIFO-Reihenfolge)
for item in stack2 {
    print(item) // c, b, a
}
```

### Queue

```swift
var queue = Queue<String>()
queue.enqueue("erste")
queue.enqueue("zweite")
queue.enqueue("dritte")

print(queue.front) // Optional("erste")
print(queue.dequeue()) // Optional("erste")

// Ringpuffer garantiert O(1) dequeue
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

// Wahlfreier Zugriff
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
// Worthäufigkeiten zählen
let text = "der schnelle braune Fuchs springt über den faulen Hund der Fuchs"
let words = text.split(separator: " ").map(String.init)
var bag = Bag(words)

print(bag.count(of: "der"))   // 2
print(bag.count(of: "Fuchs")) // 2
print(bag.uniqueCount)        // 10
print(bag.totalCount)         // 12

// Häufigste Wörter abrufen
let top3 = bag.mostCommon(3)
// [("der", 2), ("Fuchs", 2), ("schnelle", 1)]

// Inventarsystem
var inventory: Bag = ["Schwert": 2, "Trank": 5, "Schild": 1]
inventory.insert("Trank", count: 3)
print(inventory.count(of: "Trank")) // 8

inventory.remove("Trank", count: 2)
print(inventory.count(of: "Trank")) // 6
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

// Auch sortiertes Einfügen erhält O(log n) Höhe
for i in 1...1000 {
    tree.insert(i)
}

print(tree.height) // ~10 (vs 999 für unbalancierten BST)
```

### Trie

```swift
var trie = Trie()
trie.insert("Apfel")
trie.insert("App")
trie.insert("Applikation")
trie.insert("Banane")

print(trie.contains("App"))      // true
print(trie.hasPrefix("Appl"))    // true
print(trie.words(withPrefix: "App")) // ["App", "Apfel", "Applikation"]

// Autovervollständigungsunterstützung
let suggestions = trie.words(withPrefix: userInput)
```

### Heap

```swift
// Min-Heap (kleinster zuerst)
var minHeap = Heap<Int>.minHeap()
minHeap.insert(5)
minHeap.insert(3)
minHeap.insert(7)

print(minHeap.extract()) // Optional(3)
print(minHeap.extract()) // Optional(5)

// Max-Heap (größter zuerst)
var maxHeap = Heap<Int>.maxHeap()

// Aus Sequenz in O(n) erstellen
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

// Max-Prioritätswarteschlange
var scores = PriorityQueue<Int>.maxPriorityQueue()
```

### Graph

```swift
let graph = Graph<String>(edgeType: .undirected)

graph.addEdge(from: "A", to: "B", weight: 1)
graph.addEdge(from: "B", to: "C", weight: 2)
graph.addEdge(from: "A", to: "C", weight: 5)

// BFS-Traversierung
graph.bfs(from: "A") { vertex in
    print("Besucht: \(vertex)")
    return true // fortfahren
}

// Kürzester Pfad (ungewichtet)
let path = graph.shortestPath(from: "A", to: "C")
print(path) // ["A", "B", "C"]

// Dijkstra-Algorithmus (gewichtet)
let distances = graph.dijkstra(from: "A")
print(distances["C"]?.distance) // 3.0 (über B)
```

### LRUCache

```swift
let cache = LRUCache<String, Data>(capacity: 100)

// Speichern
cache.set("image_123", value: imageData)

// Abrufen (markiert als kürzlich verwendet)
if let data = cache.get("image_123") {
    display(data)
}

// Subscript-Syntax
cache["schlüssel"] = wert
let abgerufen = cache["schlüssel"]

// Automatische Verdrängung bei Kapazitätserreichung
```

## Designprinzipien

Diese Bibliothek folgt strengen Designprinzipien, die in Architecture Decision Records (ADRs) dokumentiert sind:

- **ADR-001: Kopiersemantik** - Werttypen verwenden Copy-on-Write; Referenztypen für komplexe Strukturen
- **ADR-002: ABI-Stabilität** - Quellkompatibilität garantiert; Binärkompatibilität nicht versprochen
- **ADR-003: Leistungsaudit** - Alle Komplexitäten mit Benchmarks verifiziert

### Protokollkonformitäten

Alle anwendbaren Typen konformieren zu:
- `Sequence` / `Collection` / `RandomAccessCollection`
- `ExpressibleByArrayLiteral`
- `Equatable` / `Hashable` (wenn Element konformiert)
- `Sendable` (wenn Element Sendable ist)
- `CustomStringConvertible`

## Anforderungen

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+ / visionOS 1+

## Mitwirken

Beiträge sind willkommen! Bitte lesen Sie unseren [Beitragsleitfaden](CONTRIBUTING.md) und die ADR-Dokumente in `/Documentation/ADR/` vor dem Mitwirken, um unseren Entwicklungsprozess und die Designentscheidungen zu verstehen.

## Lizenz

MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.
