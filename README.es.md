# DataStructuresKit

🌐 Idioma: [Deutsch](README.de.md) | [English](README.md) | Español | [Français](README.fr.md)

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015+%20|%20macOS%2012+%20|%20tvOS%2015+%20|%20watchOS%208+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Una colección completa y lista para producción de estructuras de datos para Swift, llenando los vacíos de la biblioteca estándar con implementaciones de alto rendimiento y bien documentadas.

## Características

- 🚀 **Alto rendimiento**: Todas las operaciones cumplen o superan las garantías de complejidad documentadas
- 📖 **Completamente documentado**: Documentación compatible con DocC con ejemplos
- 🧪 **Exhaustivamente probado**: Suite de pruebas completa usando Swift Testing
- 🔒 **Tipo seguro**: Implementaciones genéricas con conformidades de protocolo completas
- 📦 **Cero dependencias**: Implementación Swift pura (excepto biblioteca estándar)
- 🧵 **Listo para Sendable**: Anotaciones de concurrencia apropiadas para Swift moderno

## Instalación

### Swift Package Manager

Añade a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/hoseiocean/DataStructuresKit.git", from: "1.0.0")
]
```

O en Xcode: Archivo → Añadir dependencias de paquete → Introduce la URL del repositorio.

## Estructuras de datos

### Estructuras lineales

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`Stack<T>`](#stack) | Colección LIFO | push O(1), pop O(1) |
| [`Queue<T>`](#queue) | Colección FIFO (buffer circular) | enqueue O(1), dequeue O(1) |
| [`Deque<T>`](#deque) | Cola de doble extremo | pushFront/Back O(1), popFront/Back O(1) |
| [`LinkedList<T>`](#linkedlist) | Lista doblemente enlazada | insert O(1), remove O(1) |

### Colecciones

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`Bag<T>`](#bag) | Multiconjunto (cuenta duplicados) | insert O(1), count(of:) O(1) |

### Árboles

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`BinarySearchTree<T>`](#binarysearchtree) | ABB con O(log n) promedio | insert, search, remove |
| [`AVLTree<T>`](#avltree) | ABB autobalanceado | insert O(log n) garantizado |
| [`Trie`](#trie) | Árbol de prefijos para cadenas | insert O(m), búsqueda de prefijo O(m) |

### Montículos y colas de prioridad

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`Heap<T>`](#heap) | Montículo binario (min/max) | insert O(log n), extract O(log n) |
| [`PriorityQueue<T>`](#priorityqueue) | Wrapper de cola de prioridad | insert O(log n), extractTop O(log n) |

### Grafos

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`Graph<T>`](#graph) | Grafo por lista de adyacencia | BFS, DFS, Dijkstra O(V+E) |

### Cachés

| Estructura | Descripción | Operaciones clave |
|------------|-------------|-------------------|
| [`LRUCache<K,V>`](#lrucache) | Caché Least Recently Used | get O(1), set O(1) |

## Ejemplos de uso

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

// Inicialización por literal de array
let stack2: Stack = ["a", "b", "c"]

// Iteración (orden LIFO)
for item in stack2 {
    print(item) // c, b, a
}
```

### Queue

```swift
var queue = Queue<String>()
queue.enqueue("primero")
queue.enqueue("segundo")
queue.enqueue("tercero")

print(queue.front) // Optional("primero")
print(queue.dequeue()) // Optional("primero")

// El buffer circular garantiza dequeue en O(1)
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

// Acceso aleatorio
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
// Contar frecuencias de palabras
let text = "el rápido zorro marrón salta sobre el perro perezoso el zorro"
let words = text.split(separator: " ").map(String.init)
var bag = Bag(words)

print(bag.count(of: "el"))    // 3
print(bag.count(of: "zorro")) // 2
print(bag.uniqueCount)        // 9
print(bag.totalCount)         // 11

// Obtener palabras más comunes
let top3 = bag.mostCommon(3)
// [("el", 3), ("zorro", 2), ("rápido", 1)]

// Sistema de inventario
var inventory: Bag = ["espada": 2, "poción": 5, "escudo": 1]
inventory.insert("poción", count: 3)
print(inventory.count(of: "poción")) // 8

inventory.remove("poción", count: 2)
print(inventory.count(of: "poción")) // 6
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

// Incluso la inserción ordenada mantiene altura O(log n)
for i in 1...1000 {
    tree.insert(i)
}

print(tree.height) // ~10 (vs 999 para ABB no balanceado)
```

### Trie

```swift
var trie = Trie()
trie.insert("manzana")
trie.insert("man")
trie.insert("aplicación")
trie.insert("banana")

print(trie.contains("man"))       // true
print(trie.hasPrefix("manz"))     // true
print(trie.words(withPrefix: "man")) // ["man", "manzana"]

// Soporte de autocompletado
let suggestions = trie.words(withPrefix: userInput)
```

### Heap

```swift
// Montículo min (menor primero)
var minHeap = Heap<Int>.minHeap()
minHeap.insert(5)
minHeap.insert(3)
minHeap.insert(7)

print(minHeap.extract()) // Optional(3)
print(minHeap.extract()) // Optional(5)

// Montículo max (mayor primero)
var maxHeap = Heap<Int>.maxHeap()

// Construir desde secuencia en O(n)
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

// Cola de prioridad max
var scores = PriorityQueue<Int>.maxPriorityQueue()
```

### Graph

```swift
let graph = Graph<String>(edgeType: .undirected)

graph.addEdge(from: "A", to: "B", weight: 1)
graph.addEdge(from: "B", to: "C", weight: 2)
graph.addEdge(from: "A", to: "C", weight: 5)

// Recorrido BFS
graph.bfs(from: "A") { vertex in
    print("Visitado: \(vertex)")
    return true // continuar
}

// Camino más corto (no ponderado)
let path = graph.shortestPath(from: "A", to: "C")
print(path) // ["A", "B", "C"]

// Algoritmo de Dijkstra (ponderado)
let distances = graph.dijkstra(from: "A")
print(distances["C"]?.distance) // 3.0 (vía B)
```

### LRUCache

```swift
let cache = LRUCache<String, Data>(capacity: 100)

// Almacenar
cache.set("image_123", value: imageData)

// Recuperar (marca como usado recientemente)
if let data = cache.get("image_123") {
    display(data)
}

// Sintaxis subscript
cache["clave"] = valor
let recuperado = cache["clave"]

// Desalojo automático cuando se alcanza la capacidad
```

## Principios de diseño

Esta biblioteca sigue principios de diseño estrictos documentados en Architecture Decision Records (ADRs):

- **ADR-001: Semántica de copia** - Los tipos de valor usan Copy-on-Write; tipos de referencia para estructuras complejas
- **ADR-002: Estabilidad ABI** - Compatibilidad de fuente garantizada; compatibilidad binaria no prometida
- **ADR-003: Auditoría de rendimiento** - Todas las complejidades verificadas con benchmarks

### Conformidades de protocolo

Todos los tipos aplicables se conforman a:
- `Sequence` / `Collection` / `RandomAccessCollection`
- `ExpressibleByArrayLiteral`
- `Equatable` / `Hashable` (cuando Element se conforma)
- `Sendable` (cuando Element es Sendable)
- `CustomStringConvertible`

## Requisitos

- Swift 5.9+
- iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+ / visionOS 1+

## Contribuir

¡Las contribuciones son bienvenidas! Por favor lee nuestra [Guía de contribución](CONTRIBUTING.md) y los documentos ADR en `/Documentation/ADR/` antes de contribuir para entender nuestro proceso de desarrollo y las decisiones de diseño.

## Licencia

Licencia MIT - ver [LICENSE](LICENSE) para detalles.
