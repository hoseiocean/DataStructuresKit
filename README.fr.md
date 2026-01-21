# DataStructuresKit

🌐 Langue : [Deutsch](README.de.md) | [English](README.md) | [Español](README.es.md) | Français

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Une collection complète et prête pour la production de structures de données pour Swift, comblant les lacunes de la bibliothèque standard avec des implémentations performantes et bien documentées.

[![Documentation](https://img.shields.io/badge/DocC-Documentation-blue?logo=swift)](https://hoseiocean.github.io/DataStructuresKit/documentation/datastructureskit/)

## Fonctionnalités

- 🚀 **Haute performance** : Toutes les opérations respectent ou dépassent les garanties de complexité documentées
- 📖 **Entièrement documenté** : Documentation compatible DocC avec exemples
- 🧪 **Tests exhaustifs** : Suite de tests complète utilisant Swift Testing
- 🔒 **Typage sûr** : Implémentations génériques avec conformités protocolaires complètes
- 📦 **Zéro dépendance** : Implémentation Swift pure (sauf bibliothèque standard)
- 🧵 **Prêt pour Sendable** : Annotations de concurrence appropriées pour Swift moderne

## Installation

### Swift Package Manager

Ajoutez à votre `Package.swift` :

```swift
dependencies: [
    .package(url: "https://github.com/hoseiocean/DataStructuresKit.git", from: "1.0.0")
]
```

Ou dans Xcode : Fichier → Ajouter des dépendances de package → Entrez l'URL du dépôt :
```
https://github.com/hoseiocean/DataStructuresKit.git
```

## Structures de données

### Structures linéaires

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`Stack<T>`](#stack) | Collection LIFO | push O(1), pop O(1) |
| [`Queue<T>`](#queue) | Collection FIFO (tampon circulaire) | enqueue O(1), dequeue O(1) |
| [`Deque<T>`](#deque) | File à double extrémité | pushFront/Back O(1), popFront/Back O(1) |
| [`LinkedList<T>`](#linkedlist) | Liste doublement chaînée | insert O(1), remove O(1) |

### Collections

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`Bag<T>`](#bag) | Multiensemble (compte les doublons) | insert O(1), count(of:) O(1) |

### Arbres

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`BinarySearchTree<T>`](#binarysearchtree) | ABR avec O(log n) en moyenne | insert, search, remove |
| [`AVLTree<T>`](#avltree) | ABR auto-équilibré | insert O(log n) garanti |
| [`Trie`](#trie) | Arbre préfixe pour chaînes | insert O(m), recherche préfixe O(m) |

### Tas et files de priorité

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`Heap<T>`](#heap) | Tas binaire (min/max) | insert O(log n), extract O(log n) |
| [`PriorityQueue<T>`](#priorityqueue) | Wrapper de file de priorité | insert O(log n), extractTop O(log n) |

### Graphes

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`Graph<T>`](#graph) | Graphe par liste d'adjacence | BFS, DFS, Dijkstra O(V+E) |

### Caches

| Structure | Description | Opérations clés |
|-----------|-------------|-----------------|
| [`LRUCache<K,V>`](#lrucache) | Cache Least Recently Used | get O(1), set O(1) |

## Exemples d'utilisation

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

// Initialisation par littéral de tableau
let stack2: Stack = ["a", "b", "c"]

// Itération (ordre LIFO)
for item in stack2 {
    print(item) // c, b, a
}
```

### Queue

```swift
var queue = Queue<String>()
queue.enqueue("premier")
queue.enqueue("deuxième")
queue.enqueue("troisième")

print(queue.front) // Optional("premier")
print(queue.dequeue()) // Optional("premier")

// Le tampon circulaire garantit un dequeue en O(1)
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

// Accès aléatoire
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
// Compter les fréquences de mots
let text = "le renard brun rapide saute par-dessus le chien paresseux le renard"
let words = text.split(separator: " ").map(String.init)
var bag = Bag(words)

print(bag.count(of: "le"))     // 3
print(bag.count(of: "renard")) // 2
print(bag.uniqueCount)         // 9
print(bag.totalCount)          // 11

// Obtenir les mots les plus fréquents
let top3 = bag.mostCommon(3)
// [("le", 3), ("renard", 2), ("brun", 1)]

// Système d'inventaire
var inventory: Bag = ["épée": 2, "potion": 5, "bouclier": 1]
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

// Même une insertion triée maintient une hauteur O(log n)
for i in 1...1000 {
    tree.insert(i)
}

print(tree.height) // ~10 (vs 999 pour un ABR non équilibré)
```

### Trie

```swift
var trie = Trie()
trie.insert("pomme")
trie.insert("pom")
trie.insert("application")
trie.insert("banane")

print(trie.contains("pom"))      // true
print(trie.hasPrefix("pomm"))    // true
print(trie.words(withPrefix: "pom")) // ["pom", "pomme"]

// Support de l'autocomplétion
let suggestions = trie.words(withPrefix: userInput)
```

### Heap

```swift
// Tas min (plus petit d'abord)
var minHeap = Heap<Int>.minHeap()
minHeap.insert(5)
minHeap.insert(3)
minHeap.insert(7)

print(minHeap.extract()) // Optional(3)
print(minHeap.extract()) // Optional(5)

// Tas max (plus grand d'abord)
var maxHeap = Heap<Int>.maxHeap()

// Construction depuis une séquence en O(n)
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

// File de priorité max
var scores = PriorityQueue<Int>.maxPriorityQueue()
```

### Graph

```swift
let graph = Graph<String>(edgeType: .undirected)

graph.addEdge(from: "A", to: "B", weight: 1)
graph.addEdge(from: "B", to: "C", weight: 2)
graph.addEdge(from: "A", to: "C", weight: 5)

// Parcours BFS
graph.bfs(from: "A") { vertex in
    print("Visité : \(vertex)")
    return true // continuer
}

// Plus court chemin (non pondéré)
let path = graph.shortestPath(from: "A", to: "C")
print(path) // ["A", "B", "C"]

// Algorithme de Dijkstra (pondéré)
let distances = graph.dijkstra(from: "A")
print(distances["C"]?.distance) // 3.0 (via B)
```

### LRUCache

```swift
let cache = LRUCache<String, Data>(capacity: 100)

// Stocker
cache.set("image_123", value: imageData)

// Récupérer (marque comme récemment utilisé)
if let data = cache.get("image_123") {
    display(data)
}

// Syntaxe subscript
cache["clé"] = valeur
let récupéré = cache["clé"]

// Éviction automatique quand la capacité est atteinte
```

## Principes de conception

Cette bibliothèque suit des principes de conception stricts documentés dans les Architecture Decision Records (ADR) :

- **ADR-001 : Sémantique de copie** - Les types valeur utilisent Copy-on-Write ; types référence pour les structures complexes
- **ADR-002 : Stabilité ABI** - Compatibilité source garantie ; compatibilité binaire non promise
- **ADR-003 : Audit de performance** - Toutes les complexités vérifiées avec des benchmarks

### Conformités protocolaires

Tous les types applicables se conforment à :
- `Sequence` / `Collection` / `RandomAccessCollection`
- `ExpressibleByArrayLiteral`
- `Equatable` / `Hashable` (quand Element se conforme)
- `Sendable` (quand Element est Sendable)
- `CustomStringConvertible`

## Prérequis

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+ / visionOS 1+

## Contribuer

Les contributions sont les bienvenues ! Veuillez lire notre [Guide de contribution](CONTRIBUTING.md) et les documents ADR dans `/Documentation/ADR/` avant de contribuer pour comprendre notre processus de développement et les décisions de conception.

## Licence

Licence MIT - voir [LICENSE](LICENSE) pour les détails.
