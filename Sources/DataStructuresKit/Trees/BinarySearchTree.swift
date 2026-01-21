// MARK: - BinarySearchTree
// A binary search tree with O(log n) average operations.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - recursive node structure ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(log n) average, O(n) worst case operations ✓

/// A binary search tree providing efficient search, insertion, and deletion.
///
/// `BinarySearchTree` maintains the BST property: for each node, all values
/// in the left subtree are smaller, and all values in the right subtree are larger.
///
/// ## Performance
///
/// | Operation | Average | Worst Case |
/// |-----------|---------|------------|
/// | insert(_:) | O(log n) | O(n) |
/// | contains(_:) | O(log n) | O(n) |
/// | remove(_:) | O(log n) | O(n) |
/// | min/max | O(log n) | O(n) |
///
/// For guaranteed O(log n) operations, use `AVLTree` instead.
///
/// ## Example
///
/// ```swift
/// var bst = BinarySearchTree<Int>()
/// bst.insert(5)
/// bst.insert(3)
/// bst.insert(7)
/// bst.insert(1)
///
/// print(bst.contains(3)) // true
/// print(bst.min)         // Optional(1)
/// print(bst.max)         // Optional(7)
///
/// for value in bst {     // In-order traversal
///     print(value)       // 1, 3, 5, 7
/// }
/// ```
public final class BinarySearchTree<Element: Comparable> {
    
    // MARK: - Node
    
    /// A node in the binary search tree.
    public final class Node {
        /// The value stored in this node.
        public var value: Element
        
        /// The left child (smaller values).
        public internal(set) var left: Node?
        
        /// The right child (larger values).
        public internal(set) var right: Node?
        
        /// The parent node.
        public internal(set) weak var parent: Node?
        
        /// Creates a node with the given value.
        @usableFromInline
        internal init(value: Element) {
            self.value = value
        }
        
        /// A Boolean value indicating whether this is a leaf node.
        @inlinable
        public var isLeaf: Bool { left == nil && right == nil }
        
        /// The height of the subtree rooted at this node.
        public var height: Int {
            let leftHeight = left?.height ?? -1
            let rightHeight = right?.height ?? -1
            return 1 + Swift.max(leftHeight, rightHeight)
        }
        
        /// The number of nodes in the subtree rooted at this node.
        public var subtreeCount: Int {
            1 + (left?.subtreeCount ?? 0) + (right?.subtreeCount ?? 0)
        }
    }
    
    // MARK: - Properties
    
    /// The root node of the tree.
    public private(set) var root: Node?
    
    /// The number of elements in the tree.
    public private(set) var count: Int = 0
    
    /// A Boolean value indicating whether the tree is empty.
    @inlinable
    public var isEmpty: Bool { root == nil }
    
    /// The height of the tree.
    public var height: Int { root?.height ?? -1 }
    
    /// The minimum value in the tree.
    public var min: Element? { minNode(from: root)?.value }
    
    /// The maximum value in the tree.
    public var max: Element? { maxNode(from: root)?.value }
    
    // MARK: - Initialization
    
    /// Creates an empty binary search tree.
    public init() {}
    
    /// Creates a binary search tree from a sequence.
    ///
    /// - Parameter elements: The elements to insert.
    /// - Complexity: O(n log n) average, O(n²) worst case.
    public init<S: Sequence>(_ elements: S) where S.Element == Element {
        for element in elements {
            insert(element)
        }
    }
    
    // MARK: - Search
    
    /// Returns whether the tree contains the specified value.
    ///
    /// - Complexity: O(log n) average, O(n) worst case.
    public func contains(_ value: Element) -> Bool {
        search(value) != nil
    }
    
    /// Searches for a value and returns its node.
    ///
    /// - Parameter value: The value to search for.
    /// - Returns: The node containing the value, or `nil` if not found.
    /// - Complexity: O(log n) average, O(n) worst case.
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
    
    /// Inserts a value into the tree.
    ///
    /// If the value already exists, no insertion occurs.
    ///
    /// - Parameter value: The value to insert.
    /// - Returns: The node containing the value (new or existing).
    /// - Complexity: O(log n) average, O(n) worst case.
    @discardableResult
    public func insert(_ value: Element) -> Node {
        if let existing = search(value) {
            return existing
        }
        
        let newNode = Node(value: value)
        
        guard let root = root else {
            self.root = newNode
            count += 1
            return newNode
        }
        
        var current: Node? = root
        var parent: Node?
        
        while let node = current {
            parent = node
            if value < node.value {
                current = node.left
            } else {
                current = node.right
            }
        }
        
        newNode.parent = parent
        if value < parent!.value {
            parent!.left = newNode
        } else {
            parent!.right = newNode
        }
        
        count += 1
        return newNode
    }
    
    // MARK: - Removal
    
    /// Removes a value from the tree.
    ///
    /// - Parameter value: The value to remove.
    /// - Returns: `true` if the value was found and removed.
    /// - Complexity: O(log n) average, O(n) worst case.
    @discardableResult
    public func remove(_ value: Element) -> Bool {
        guard let node = search(value) else { return false }
        removeNode(node)
        count -= 1
        return true
    }
    
    /// Removes all elements from the tree.
    public func removeAll() {
        root = nil
        count = 0
    }
    
    // MARK: - Private Helpers
    
    private func removeNode(_ node: Node) {
        // Case 1: No children
        if node.isLeaf {
            replaceNode(node, with: nil)
        }
        // Case 2: One child
        else if node.left == nil {
            replaceNode(node, with: node.right)
        } else if node.right == nil {
            replaceNode(node, with: node.left)
        }
        // Case 3: Two children - replace with in-order successor
        else {
            let successor = minNode(from: node.right!)!
            node.value = successor.value
            removeNode(successor)
        }
    }
    
    private func replaceNode(_ node: Node, with replacement: Node?) {
        if let parent = node.parent {
            if node === parent.left {
                parent.left = replacement
            } else {
                parent.right = replacement
            }
        } else {
            root = replacement
        }
        replacement?.parent = node.parent
    }
    
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
    
    /// Performs an in-order traversal (sorted order).
    public func traverseInOrder(_ visit: (Element) -> Void) {
        inOrderHelper(root, visit)
    }
    
    private func inOrderHelper(_ node: Node?, _ visit: (Element) -> Void) {
        guard let node = node else { return }
        inOrderHelper(node.left, visit)
        visit(node.value)
        inOrderHelper(node.right, visit)
    }
    
    /// Performs a pre-order traversal.
    public func traversePreOrder(_ visit: (Element) -> Void) {
        preOrderHelper(root, visit)
    }
    
    private func preOrderHelper(_ node: Node?, _ visit: (Element) -> Void) {
        guard let node = node else { return }
        visit(node.value)
        preOrderHelper(node.left, visit)
        preOrderHelper(node.right, visit)
    }
    
    /// Performs a post-order traversal.
    public func traversePostOrder(_ visit: (Element) -> Void) {
        postOrderHelper(root, visit)
    }
    
    private func postOrderHelper(_ node: Node?, _ visit: (Element) -> Void) {
        guard let node = node else { return }
        postOrderHelper(node.left, visit)
        postOrderHelper(node.right, visit)
        visit(node.value)
    }
    
    /// Performs a level-order (breadth-first) traversal.
    public func traverseLevelOrder(_ visit: (Element) -> Void) {
        guard let root = root else { return }
        
        var queue = Queue<Node>()
        queue.enqueue(root)
        
        while let node = queue.dequeue() {
            visit(node.value)
            if let left = node.left { queue.enqueue(left) }
            if let right = node.right { queue.enqueue(right) }
        }
    }
    
    /// Returns all elements in sorted order.
    public var sorted: [Element] {
        var result: [Element] = []
        result.reserveCapacity(count)
        traverseInOrder { result.append($0) }
        return result
    }
    
    /// Creates a copy of the tree.
    public func copy() -> BinarySearchTree {
        let newTree = BinarySearchTree()
        traversePreOrder { newTree.insert($0) }
        return newTree
    }
}

// MARK: - Sequence Conformance (In-Order)

extension BinarySearchTree: Sequence {
    /// An iterator that traverses the tree in sorted order.
    public struct Iterator: IteratorProtocol {
        private var stack: [Node] = []
        
        internal init(_ tree: BinarySearchTree) {
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

extension BinarySearchTree: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

// MARK: - CustomStringConvertible

extension BinarySearchTree: CustomStringConvertible {
    public var description: String {
        "BinarySearchTree<\(Element.self)>(count: \(count), height: \(height), sorted: \(sorted))"
    }
}

// MARK: - Countable

extension BinarySearchTree: Countable {}
