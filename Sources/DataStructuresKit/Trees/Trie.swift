// MARK: - Trie
// A prefix tree for efficient string operations.
//
// ADR Compliance:
// - ADR-001: Reference type (class) - tree structure with shared prefixes ✓
// - ADR-002: Full API documentation ✓
// - ADR-003: O(m) operations where m = string length ✓

/// A prefix tree (trie) for efficient string storage and prefix-based search.
///
/// `Trie` excels at storing strings with shared prefixes and provides
/// extremely fast prefix searches. It's ideal for autocomplete, spell-checking,
/// and IP routing tables.
///
/// ## When to Use Trie
///
/// - Autocomplete / typeahead suggestions
/// - Spell-checking with prefix matching
/// - Dictionary with word lookup
/// - IP address routing (longest prefix match)
///
/// ## Example
///
/// ```swift
/// var trie = Trie()
/// trie.insert("apple")
/// trie.insert("app")
/// trie.insert("application")
/// trie.insert("banana")
///
/// print(trie.contains("app"))        // true
/// print(trie.contains("appl"))       // false (not a complete word)
/// print(trie.hasPrefix("app"))       // true
///
/// print(trie.words(withPrefix: "app"))
/// // ["app", "apple", "application"]
/// ```
///
/// ## Performance
///
/// | Operation | Complexity |
/// |-----------|------------|
/// | insert(_:) | O(m) |
/// | contains(_:) | O(m) |
/// | hasPrefix(_:) | O(m) |
/// | words(withPrefix:) | O(m + k) |
/// | remove(_:) | O(m) |
///
/// Where m = string length, k = number of matching words.
public final class Trie {
    
    // MARK: - Node
    
    /// A node in the trie representing a character position.
    public final class TrieNode {
        /// Children keyed by character.
        public internal(set) var children: [Character: TrieNode] = [:]
        
        /// Whether this node marks the end of a complete word.
        public internal(set) var isEndOfWord: Bool = false
        
        /// The complete word if this is an end node.
        public internal(set) var word: String?
        
        @usableFromInline
        internal init() {}
    }
    
    // MARK: - Properties
    
    /// The root node of the trie.
    public let root = TrieNode()
    
    /// The number of words in the trie.
    public private(set) var count: Int = 0
    
    /// A Boolean value indicating whether the trie is empty.
    @inlinable
    public var isEmpty: Bool { count == 0 }
    
    // MARK: - Initialization
    
    /// Creates an empty trie.
    public init() {}
    
    /// Creates a trie containing the given words.
    ///
    /// - Parameter words: The words to insert.
    /// - Complexity: O(n × m) where n = number of words, m = average length.
    public init<S: Sequence>(_ words: S) where S.Element == String {
        for word in words {
            insert(word)
        }
    }
    
    // MARK: - Insertion
    
    /// Inserts a word into the trie.
    ///
    /// - Parameter word: The word to insert.
    /// - Complexity: O(m) where m = word length.
    public func insert(_ word: String) {
        guard !word.isEmpty else { return }
        
        var current = root
        
        for char in word {
            if let child = current.children[char] {
                current = child
            } else {
                let node = TrieNode()
                current.children[char] = node
                current = node
            }
        }
        
        if !current.isEndOfWord {
            current.isEndOfWord = true
            current.word = word
            count += 1
        }
    }
    
    // MARK: - Search
    
    /// Returns whether the trie contains the exact word.
    ///
    /// - Parameter word: The word to search for.
    /// - Returns: `true` if the word exists as a complete word.
    /// - Complexity: O(m)
    public func contains(_ word: String) -> Bool {
        guard let node = findNode(for: word) else { return false }
        return node.isEndOfWord
    }
    
    /// Returns whether any word in the trie starts with the given prefix.
    ///
    /// - Parameter prefix: The prefix to search for.
    /// - Returns: `true` if any word has this prefix.
    /// - Complexity: O(m)
    public func hasPrefix(_ prefix: String) -> Bool {
        findNode(for: prefix) != nil
    }
    
    /// Returns all words with the given prefix.
    ///
    /// - Parameter prefix: The prefix to search for.
    /// - Returns: An array of all matching words.
    /// - Complexity: O(m + k) where k = number of matching words.
    public func words(withPrefix prefix: String) -> [String] {
        guard let node = findNode(for: prefix) else { return [] }
        return collectWords(from: node)
    }
    
    /// Returns all words in the trie.
    ///
    /// - Complexity: O(total characters in trie)
    public var allWords: [String] {
        collectWords(from: root)
    }
    
    // MARK: - Removal
    
    /// Removes a word from the trie.
    ///
    /// - Parameter word: The word to remove.
    /// - Returns: `true` if the word was found and removed.
    /// - Complexity: O(m)
    @discardableResult
    public func remove(_ word: String) -> Bool {
        guard !word.isEmpty, contains(word) else { return false }
        count -= 1
        return removeHelper(word, from: root, index: word.startIndex)
    }
    
    /// Removes all words from the trie.
    public func removeAll() {
        root.children.removeAll()
        count = 0
    }
    
    // MARK: - Private Helpers
    
    private func findNode(for string: String) -> TrieNode? {
        var current = root
        for char in string {
            guard let child = current.children[char] else { return nil }
            current = child
        }
        return current
    }
    
    private func collectWords(from node: TrieNode) -> [String] {
        var words: [String] = []
        
        if node.isEndOfWord, let word = node.word {
            words.append(word)
        }
        
        for child in node.children.values {
            words.append(contentsOf: collectWords(from: child))
        }
        
        return words
    }
    
    private func removeHelper(_ word: String, from node: TrieNode, index: String.Index) -> Bool {
        if index == word.endIndex {
            node.isEndOfWord = false
            node.word = nil
            return node.children.isEmpty
        }
        
        let char = word[index]
        guard let child = node.children[char] else { return false }
        
        let shouldDeleteChild = removeHelper(word, from: child, index: word.index(after: index))
        
        if shouldDeleteChild {
            node.children.removeValue(forKey: char)
            return !node.isEndOfWord && node.children.isEmpty
        }
        
        return false
    }
    
    // MARK: - Advanced Operations
    
    /// Finds the longest word that is a prefix of the input.
    ///
    /// - Parameter text: The text to search in.
    /// - Returns: The longest matching word, or `nil` if none.
    /// - Complexity: O(m)
    public func longestPrefix(of text: String) -> String? {
        var current = root
        var lastWord: String?
        
        for char in text {
            guard let child = current.children[char] else { break }
            current = child
            if current.isEndOfWord {
                lastWord = current.word
            }
        }
        
        return lastWord
    }
    
    /// Returns words matching a pattern with wildcards.
    ///
    /// Use '.' as a wildcard matching any single character.
    ///
    /// - Parameter pattern: The pattern to match.
    /// - Returns: All matching words.
    /// - Complexity: O(26^w × m) where w = number of wildcards.
    public func wordsMatching(pattern: String) -> [String] {
        var results: [String] = []
        matchPattern(pattern, pattern.startIndex, root, &results)
        return results
    }
    
    private func matchPattern(_ pattern: String, _ index: String.Index, _ node: TrieNode, _ results: inout [String]) {
        if index == pattern.endIndex {
            if node.isEndOfWord, let word = node.word {
                results.append(word)
            }
            return
        }
        
        let char = pattern[index]
        let nextIndex = pattern.index(after: index)
        
        if char == "." {
            // Wildcard: try all children
            for child in node.children.values {
                matchPattern(pattern, nextIndex, child, &results)
            }
        } else if let child = node.children[char] {
            matchPattern(pattern, nextIndex, child, &results)
        }
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Trie: ExpressibleByArrayLiteral {
    public convenience init(arrayLiteral elements: String...) {
        self.init(elements)
    }
}

// MARK: - CustomStringConvertible

extension Trie: CustomStringConvertible {
    public var description: String {
        "Trie(count: \(count), words: \(allWords.prefix(10))\(count > 10 ? "..." : ""))"
    }
}

// MARK: - Countable

extension Trie: Countable {}
