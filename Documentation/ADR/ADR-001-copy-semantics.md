# ADR-001: Copy Semantics Strategy

## Status
**Accepted** - 2025-01-19

## Context

DataStructuresKit implémente des structures de données pour iOS/macOS. Nous devons décider pour chaque type s'il sera :
- **Value Type** (`struct`) avec sémantique de copie
- **Reference Type** (`class`) avec sémantique de référence

Cette décision impacte :
- La **thread-safety** (value types sont intrinsèquement thread-safe pour les lectures)
- Les **performances** (copies vs références)
- L'**API ergonomique** (mutation avec `mutating` vs méthodes classiques)
- La **compatibilité** avec les collections Swift standard

## Decision Matrix

| Structure | Type | Justification | CoW Required |
|-----------|------|---------------|--------------|
| `Stack<T>` | `struct` | Petite, mutations fréquentes, copie légère | ✅ Oui |
| `Queue<T>` | `struct` | Circular buffer, mutations fréquentes | ✅ Oui |
| `Deque<T>` | `struct` | Cohérence avec Swift Collections | ✅ Oui |
| `LinkedList<T>` | `class` | Nodes référencés, CoW complexe et coûteux | ❌ Non |
| `BinarySearchTree<T>` | `class` | Structure récursive avec parent pointers | ❌ Non |
| `AVLTree<T>` | `class` | Idem BST + rotations | ❌ Non |
| `Trie` | `class` | Structure arborescente complexe | ❌ Non |
| `Graph<T>` | `class` | Références croisées entre vertices/edges | ❌ Non |
| `Heap<T>` | `struct` | Array-based, cohérence Collections | ✅ Oui |
| `PriorityQueue<T>` | `struct` | Wrapper sur Heap | ✅ Oui |
| `LRUCache<K,V>` | `class` | Cache partagé, état mutable partagé | ❌ Non |

## Copy-on-Write Implementation Pattern

Pour les `struct` avec CoW :

```swift
public struct Stack<Element> {
    // Storage interne en classe pour permettre CoW
    private final class Storage {
        var elements: [Element]
        init(_ elements: [Element] = []) { self.elements = elements }
        func copy() -> Storage { Storage(elements) }
    }
    
    private var storage: Storage
    
    // Point critique : vérifier l'unicité avant mutation
    private mutating func ensureUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
    }
    
    public mutating func push(_ element: Element) {
        ensureUnique()
        storage.elements.append(element)
    }
}
```

## Rules

### R1: Value Types (`struct`)
- DOIVENT implémenter Copy-on-Write si le storage interne > 64 bytes
- DOIVENT utiliser `isKnownUniquelyReferenced` pour l'optimisation
- DOIVENT être marquées `@frozen` si ABI stability requise (voir ADR-002)

### R2: Reference Types (`class`)
- DOIVENT être `final` sauf si héritage explicitement prévu
- DOIVENT documenter la thread-safety (ou son absence)
- PEUVENT offrir une méthode `copy() -> Self` pour copie explicite

### R3: Sendable Conformance
- Tous les types avec `Element: Sendable` DOIVENT être `Sendable`
- Les `class` thread-safe DOIVENT être marquées `@unchecked Sendable` avec documentation

## Consequences

### Positives
- Cohérence avec la Standard Library Swift
- Prédictibilité pour les développeurs
- Performances optimales via CoW

### Negatives
- Complexité d'implémentation accrue pour CoW
- Deux patterns mentaux (value/reference) à documenter

## Compliance Checklist

Avant merge de chaque structure :
- [ ] Type correctement choisi selon la matrice
- [ ] CoW implémenté si requis
- [ ] Tests de copy semantics présents
- [ ] Documentation de thread-safety
- [ ] Conformance Sendable si applicable
