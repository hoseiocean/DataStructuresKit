# ADR-002: ABI Stability Rules

## Status
**Accepted** - 2025-01-19

## Context

ABI (Application Binary Interface) stability garantit que le code compilé reste compatible entre versions de la librairie. Pour une librairie distribuée en SPM, nous devons définir nos engagements.

## Decision

### Niveau d'engagement : **Source Compatibility Only**

DataStructuresKit garantit la **compatibilité source** (API) mais **PAS** la compatibilité binaire (ABI).

**Justification** :
- SPM recompile les dépendances → ABI stability non requise
- Flexibilité pour optimisations internes
- Réduction de la complexité

### Règles API Stability

#### R1: Public API Surface
```swift
// ✅ STABLE - Ne changera pas de signature
public mutating func push(_ element: Element)
public mutating func pop() -> Element?
public var count: Int { get }
public var isEmpty: Bool { get }

// ❌ INTERNAL - Peut changer sans préavis
internal var storage: Storage
private mutating func ensureUnique()
```

#### R2: Semantic Versioning
- **MAJOR** (1.0.0 → 2.0.0) : Breaking changes API
- **MINOR** (1.0.0 → 1.1.0) : Nouvelles fonctionnalités, backward compatible
- **PATCH** (1.0.0 → 1.0.1) : Bug fixes uniquement

#### R3: Deprecation Policy
```swift
// Étape 1 : Deprecation avec alternative (version N)
@available(*, deprecated, renamed: "removeFirst()")
public mutating func dequeue() -> Element? { removeFirst() }

// Étape 2 : Suppression (version N+2 minimum)
```

#### R4: Protocol Conformances
Une fois qu'un type est conforme à un protocole public, cette conformance est **permanente**.

```swift
// Une fois ajouté, ne peut être retiré
extension Stack: Sequence { }
extension Stack: ExpressibleByArrayLiteral { }
```

### Frozen vs Non-Frozen

#### Types `@frozen` (si ABI stability future)
```swift
// Structure interne figée - JAMAIS de nouveaux stored properties
@frozen
public struct Stack<Element> {
    private var storage: Storage  // Figé
}
```

#### Types non-frozen (défaut actuel)
```swift
// Flexibilité pour évolution interne
public struct Stack<Element> {
    private var storage: Storage
    // Peut évoluer dans versions futures
}
```

**Décision** : Aucun type n'est `@frozen` pour la v1.x. 
Réévaluation pour v2.0 si distribution binaire envisagée.

### Inlinable Strategy

```swift
// ✅ INLINABLE - Fonctions critiques pour performance
@inlinable
public var isEmpty: Bool { count == 0 }

@inlinable
public var count: Int { storage.count }

// ❌ NON-INLINABLE - Implémentation complexe pouvant évoluer
public mutating func push(_ element: Element) {
    ensureUnique()
    storage.elements.append(element)
}
```

**Règle** : Seules les fonctions triviales et stables sont `@inlinable`.

## Naming Conventions (API Guidelines)

### Méthodes de mutation
```swift
// Forme mutating : verbe à l'impératif
public mutating func append(_ element: Element)
public mutating func remove(at index: Int) -> Element

// Forme non-mutating : participe passé ou gérondif
public func appending(_ element: Element) -> Self
public func removing(at index: Int) -> Self
```

### Propriétés
```swift
// Booléens : préfixe is/has/can/should
public var isEmpty: Bool
public var hasElements: Bool { !isEmpty }

// Collections : nom au pluriel ou suffixe -count
public var count: Int
public var elements: [Element]
```

## Documentation Requirements

Chaque symbole public DOIT avoir :
```swift
/// Brief description (première ligne).
///
/// Extended discussion if needed.
///
/// - Complexity: O(1) amortized, O(n) worst case
/// - Parameter element: The element to push onto the stack.
/// - Returns: Description if applicable
/// - Throws: Description if applicable
/// - Note: Thread-safety notes
/// - Warning: Important caveats
/// - SeeAlso: Related methods
public mutating func push(_ element: Element) { }
```

## Compliance Checklist

Avant release :
- [ ] Tous les symboles publics documentés
- [ ] Aucun `@frozen` sans approbation explicite
- [ ] Deprecations avec `renamed:` ou `message:`
- [ ] CHANGELOG.md mis à jour
- [ ] Version bump selon SemVer
