import Testing
@testable import DataStructuresKit

@Suite("BinarySearchTree Tests")
struct BinarySearchTreeTests {
    
    // MARK: - Initialization
    
    @Test("Empty BST")
    func testEmptyBST() {
        let bst = BinarySearchTree<Int>()
        
        #expect(bst.isEmpty)
        #expect(bst.count == 0)
        #expect(bst.min == nil)
        #expect(bst.max == nil)
    }
    
    @Test("BST from sequence")
    func testSequenceInit() {
        let bst = BinarySearchTree([5, 3, 7, 1, 9])
        
        #expect(bst.count == 5)
        #expect(bst.min == 1)
        #expect(bst.max == 9)
    }
    
    // MARK: - Insertion
    
    @Test("Insert and contains")
    func testInsertContains() {
      let bst = BinarySearchTree<Int>()
        
        bst.insert(5)
        bst.insert(3)
        bst.insert(7)
        
        #expect(bst.contains(5))
        #expect(bst.contains(3))
        #expect(bst.contains(7))
        #expect(!bst.contains(4))
    }
    
    @Test("Insert duplicate")
    func testInsertDuplicate() {
      let bst = BinarySearchTree<Int>()
        
        bst.insert(5)
        bst.insert(5)
        
        #expect(bst.count == 1)
    }
    
    // MARK: - Removal
    
    @Test("Remove leaf node")
    func testRemoveLeaf() {
      let bst = BinarySearchTree([5, 3, 7])
        
        #expect(bst.remove(3))
        #expect(!bst.contains(3))
        #expect(bst.count == 2)
    }
    
    @Test("Remove node with one child")
    func testRemoveOneChild() {
      let bst = BinarySearchTree([5, 3, 7, 1])
        
        #expect(bst.remove(3))
        #expect(!bst.contains(3))
        #expect(bst.contains(1))
    }
    
    @Test("Remove node with two children")
    func testRemoveTwoChildren() {
      let bst = BinarySearchTree([5, 3, 7, 1, 4])
        
        #expect(bst.remove(3))
        #expect(!bst.contains(3))
        #expect(bst.contains(1))
        #expect(bst.contains(4))
    }
    
    @Test("Remove root")
    func testRemoveRoot() {
      let bst = BinarySearchTree([5, 3, 7])
        
        #expect(bst.remove(5))
        #expect(!bst.contains(5))
        #expect(bst.count == 2)
    }
    
    // MARK: - Traversals
    
    @Test("In-order traversal returns sorted elements")
    func testInOrderTraversal() {
        let bst = BinarySearchTree([5, 3, 7, 1, 9, 2, 8])
        
        #expect(bst.sorted == [1, 2, 3, 5, 7, 8, 9])
    }
    
    @Test("Sequence iteration is in-order")
    func testSequenceIteration() {
        let bst = BinarySearchTree([5, 3, 7, 1, 9])
        let result = Array(bst)
        
        #expect(result == [1, 3, 5, 7, 9])
    }
}

@Suite("AVLTree Tests")
struct AVLTreeTests {
    
    // MARK: - Balance
    
    @Test("AVL tree maintains balance on sorted insertion")
    func testBalanceOnSortedInsertion() {
      let tree = AVLTree<Int>()
        
        // Insert sorted data - would be O(n) in regular BST
        for i in 1...1000 {
            tree.insert(i)
        }
        
        // Height should be O(log n)
        // log2(1000) ≈ 10, AVL allows up to 1.44 * log2(n) ≈ 14
        #expect(tree.height <= 15)
        #expect(tree.count == 1000)
    }
    
    @Test("AVL tree maintains balance on reverse sorted insertion")
    func testBalanceOnReverseSortedInsertion() {
      let tree = AVLTree<Int>()
        
        for i in (1...100).reversed() {
            tree.insert(i)
        }
        
        #expect(tree.height <= 10)
        #expect(tree.sorted == Array(1...100))
    }
    
    // MARK: - Operations
    
    @Test("Contains and search")
    func testContainsSearch() {
        let tree = AVLTree([50, 25, 75, 10, 30, 60, 90])
        
        #expect(tree.contains(50))
        #expect(tree.contains(10))
        #expect(!tree.contains(100))
    }
    
    @Test("Remove maintains balance")
    func testRemoveMaintainsBalance() {
      let tree = AVLTree(1...100)
        
        // Remove half the elements
        for i in 1...50 {
            tree.remove(i)
        }
        
        #expect(tree.count == 50)
        #expect(tree.height <= 10)
    }
    
    // MARK: - Edge Cases
    
    @Test("Single element")
    func testSingleElement() {
      let tree = AVLTree<Int>()
        tree.insert(42)
        
        #expect(tree.height == 0)
        #expect(tree.contains(42))
    }
    
    @Test("Remove all elements")
    func testRemoveAll() {
      let tree = AVLTree([1, 2, 3, 4, 5])
        tree.removeAll()
        
        #expect(tree.isEmpty)
        #expect(tree.height == -1)
    }
}

@Suite("Trie Tests")
struct TrieTests {
    
    // MARK: - Basic Operations
    
    @Test("Empty trie")
    func testEmptyTrie() {
        let trie = Trie()
        
        #expect(trie.isEmpty)
        #expect(trie.count == 0)
        #expect(!trie.contains("test"))
    }
    
    @Test("Insert and contains")
    func testInsertContains() {
      let trie = Trie()
        
        trie.insert("apple")
        trie.insert("app")
        trie.insert("application")
        
        #expect(trie.count == 3)
        #expect(trie.contains("apple"))
        #expect(trie.contains("app"))
        #expect(trie.contains("application"))
        #expect(!trie.contains("appl"))  // Not a complete word
        #expect(!trie.contains("apply"))
    }
    
    // MARK: - Prefix Search
    
    @Test("Has prefix")
    func testHasPrefix() {
        let trie = Trie(["apple", "app", "banana"])
        
        #expect(trie.hasPrefix("app"))
        #expect(trie.hasPrefix("appl"))
        #expect(trie.hasPrefix("apple"))
        #expect(!trie.hasPrefix("orange"))
    }
    
    @Test("Words with prefix")
    func testWordsWithPrefix() {
        let trie = Trie(["apple", "app", "application", "banana"])
        
        let appWords = trie.words(withPrefix: "app").sorted()
        #expect(appWords == ["app", "apple", "application"])
        
        let banWords = trie.words(withPrefix: "ban")
        #expect(banWords == ["banana"])
        
        let noWords = trie.words(withPrefix: "xyz")
        #expect(noWords.isEmpty)
    }
    
    // MARK: - Removal
    
    @Test("Remove word")
    func testRemove() {
      let trie = Trie(["apple", "app", "application"])
        
        #expect(trie.remove("apple"))
        #expect(!trie.contains("apple"))
        #expect(trie.contains("app"))
        #expect(trie.contains("application"))
        #expect(trie.count == 2)
    }
    
    @Test("Remove non-existent word")
    func testRemoveNonExistent() {
      let trie = Trie(["apple"])
        
        #expect(!trie.remove("app"))  // Not a complete word
        #expect(!trie.remove("banana"))
    }
    
    // MARK: - Advanced
    
    @Test("Longest prefix")
    func testLongestPrefix() {
        let trie = Trie(["a", "app", "apple", "applet"])
        
        #expect(trie.longestPrefix(of: "applesauce") == "apple")
        #expect(trie.longestPrefix(of: "application") == "app")
        #expect(trie.longestPrefix(of: "banana") == nil)
    }
    
    @Test("Pattern matching with wildcards")
    func testPatternMatching() {
        let trie = Trie(["cat", "car", "card", "care", "bat"])
        
        let results = trie.wordsMatching(pattern: "ca.").sorted()
        #expect(results == ["car", "cat"])
        
        let results2 = trie.wordsMatching(pattern: "c...").sorted()
        #expect(results2 == ["card", "care"])
    }
    
    // MARK: - All Words
    
    @Test("All words")
    func testAllWords() {
        let trie = Trie(["zebra", "apple", "banana"])
        
        let allWords = trie.allWords.sorted()
        #expect(allWords == ["apple", "banana", "zebra"])
    }
}
