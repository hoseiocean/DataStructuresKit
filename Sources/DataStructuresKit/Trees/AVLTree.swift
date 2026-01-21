// MARK: - AVLTree
// A self-balancing binary search tree with guaranteed O(log n) operations.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - recursive node structure ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(log n) guaranteed for all operations ✓

/// A self-balancing binary search tree that maintains O(log n) operations.
///
/// `AVLTree` automatically rebalances after insertions and deletions to ensure
/// the tree height is always O(log n). This guarantees O(log n) worst-case
/// performance for all operations.
///
/// ## When to Use AVLTree vs BinarySearchTree
///
/// Use `AVLTree` when:
/// - You need guaranteed O(log n) operations
/// - Data may be inserted in sorted or nearly-sorted order
/// - Search operations are frequent
///
/// Use `BinarySearchTree` when:
/// - Data is randomly distributed
/// - Simplicity is preferred
/// - Slightly better constant factors are important
///
/// ## Example
///
/// ```swift
/// var tree = AVLTree<Int>()
///
/// // Even inserting sorted data, tree stays balanced
/// for i in 1...1000 {
///     tree.insert(i)
/// }
///
/// print(tree.height) // ~10 (log₂ 1000 ≈ 10)
/// print(tree.contains(500)) // true, O(log n)
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | insert(_:) | O(log n) |
/// | contains(_:) | O(log n) |
/// | remove(_:) | O(log n) |
/// | min/max | O(log n) |
public final class AVLTree<Element: Comparable> {
    
    // MARK: - Node
    
    /// A node in the AVL tree with balance tracking.
    public final class Node {
        public var value: Element
        public internal(set) var left: Node?
        public internal(set) var right: Node?
        public internal(set) weak var parent: Node?
        
        /// The height of this node's subtree.
        internal var height: Int = 0
        
        @usableFromInline
        internal init(value: Element) {
            self.value = value
        }
        
        /// The balance factor: height(left) - height(right).
        internal var balanceFactor: Int {
            (left?.height ?? -1) - (right?.height ?? -1)
        }
        
        /// Updates the height based on children.
        internal func updateHeight() {
            height = 1 + Swift.max(left?.height ?? -1, right?.height ?? -1)
        }
        
        @inlinable
        public var isLeaf: Bool { left == nil && right == nil }
    }
    
    // MARK: - Properties
    
    public private(set) var root: Node?
    public private(set) var count: Int = 0
    
    @inlinable
    public var isEmpty: Bool { root == nil }
    
    public var height: Int { root?.height ?? -1 }
    public var min: Element? { minNode(from: root)?.value }
    public var max: Element? { maxNode(from: root)?.value }
    
    // MARK: - Initialization
    
    public init() {}
    
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insert(element)
        }
    }
    
    // MARK: - Search
    
    public func contains(_ value: Element) -> Bool {
        search(value) != nil
    }
    
    public func search(_ value: Element) -> Node? {
        var current = root
        while let node = current {
            if value == node.value {
                return node
            } else if value < node.value {
                current = node.left
            } else {
                current = node.right
            }
        }
        return nil
    }
    
    // MARK: - Insertion
    
    /// Inserts a value, rebalancing if necessary.
    ///
    /// - Complexity: O(log n)
    @discardableResult
    public func insert(_ value: Element) -> Node {
        if let existing = search(value) {
            return existing
        }
        
        let newNode = Node(value: value)
        root = insertNode(newNode, into: root, parent: nil)
        count += 1
        return newNode
    }
    
    private func insertNode(_ newNode: Node, into node: Node?, parent: Node?) -> Node {
        guard let node = node else {
            newNode.parent = parent
            return newNode
        }
        
        if newNode.value < node.value {
            node.left = insertNode(newNode, into: node.left, parent: node)
        } else {
            node.right = insertNode(newNode, into: node.right, parent: node)
        }
        
        return rebalance(node)
    }
    
    // MARK: - Removal
    
    /// Removes a value, rebalancing if necessary.
    ///
    /// - Complexity: O(log n)
    @discardableResult
    public func remove(_ value: Element) -> Bool {
        guard search(value) != nil else { return false }
        root = removeNode(value, from: root)
        count -= 1
        return true
    }
    
    private func removeNode(_ value: Element, from node: Node?) -> Node? {
        guard let node = node else { return nil }
        
        if value < node.value {
            node.left = removeNode(value, from: node.left)
            node.left?.parent = node
        } else if value > node.value {
            node.right = removeNode(value, from: node.right)
            node.right?.parent = node
        } else {
            // Found node to remove
            if node.left == nil {
                return node.right
            } else if node.right == nil {
                return node.left
            }
            
            // Two children: replace with successor
            let successor = minNode(from: node.right!)!
            node.value = successor.value
            node.right = removeNode(successor.value, from: node.right)
            node.right?.parent = node
        }
        
        return rebalance(node)
    }
    
    public func removeAll() {
        root = nil
        count = 0
    }
    
    // MARK: - Balancing
    
    private func rebalance(_ node: Node) -> Node {
        node.updateHeight()
        
        let bf = node.balanceFactor
        
        // Left-heavy
        if bf > 1 {
            if let left = node.left, left.balanceFactor < 0 {
                // Left-Right case
                node.left = rotateLeft(left)
            }
            return rotateRight(node)
        }
        
        // Right-heavy
        if bf < -1 {
            if let right = node.right, right.balanceFactor > 0 {
                // Right-Left case
                node.right = rotateRight(right)
            }
            return rotateLeft(node)
        }
        
        return node
    }
    
    private func rotateLeft(_ node: Node) -> Node {
        let pivot = node.right!
        let pivotLeft = pivot.left
        
        pivot.left = node
        node.right = pivotLeft
        
        pivot.parent = node.parent
        node.parent = pivot
        pivotLeft?.parent = node
        
        node.updateHeight()
        pivot.updateHeight()
        
        return pivot
    }
    
    private func rotateRight(_ node: Node) -> Node {
        let pivot = node.left!
        let pivotRight = pivot.right
        
        pivot.right = node
        node.left = pivotRight
        
        pivot.parent = node.parent
        node.parent = pivot
        pivotRight?.parent = node
        
        node.updateHeight()
        pivot.updateHeight()
        
        return pivot
    }
    
    // MARK: - Helpers
    
    private func minNode(from node: Node?) -> Node? {
        var current = node
        while let left = current?.left {
            current = left
        }
        return current
    }
    
    private func maxNode(from node: Node?) -> Node? {
        var current = node
        while let right = current?.right {
            current = right
        }
        return current
    }
    
    // MARK: - Traversals
    
    public func traverseInOrder(_ visit: (Element) -> Void) {
        inOrder(root, visit)
    }
    
    private func inOrder(_ node: Node?, _ visit: (Element) -> Void) {
        guard let node = node else { return }
        inOrder(node.left, visit)
        visit(node.value)
        inOrder(node.right, visit)
    }
    
    public var sorted: [Element] {
        var result: [Element] = []
        result.reserveCapacity(count)
        traverseInOrder { result.append($0) }
        return result
    }
    
    public func copy() -> AVLTree {
        let newTree = AVLTree()
        // Pre-order to maintain balance
        func preOrder(_ node: Node?) {
            guard let node = node else { return }
            newTree.insert(node.value)
            preOrder(node.left)
            preOrder(node.right)
        }
        preOrder(root)
        return newTree
    }
}

// MARK: - Sequence Conformance

extension AVLTree: Sequence {
    public struct Iterator: IteratorProtocol {
        private var stack: [Node] = []
        
        internal init(_ tree: AVLTree) {
            pushLeftPath(tree.root)
        }
        
        private mutating func pushLeftPath(_ node: Node?) {
            var current = node
            while let n = current {
                stack.append(n)
                current = n.left
            }
        }
        
        public mutating func next() -> Element? {
            guard !stack.isEmpty else { return nil }
            let node = stack.removeLast()
            pushLeftPath(node.right)
            return node.value
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(self)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension AVLTree: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - CustomStringConvertible

extension AVLTree: CustomStringConvertible {
    public var description: String {
        "AVLTree<\(Element.self)>(count: \(count), height: \(height))"
    }
}

// MARK: - Countable

extension AVLTree: Countable {}
