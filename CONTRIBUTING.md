# Contributing to DataStructuresKit

First off, thank you for considering contributing to DataStructuresKit! This library aims to fill gaps in the Swift Standard Library with production-ready, performance-optimized data structures.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Principles](#development-principles)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

## Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/hoseiocean/DataStructuresKit.git`
3. Read the ADR documents in `/Documentation/ADR/` to understand existing design decisions
4. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `swift test`
6. Commit and push your changes
7. Open a Pull Request

## Development Principles

DataStructuresKit follows strict software engineering principles. All contributions must adhere to:

### TDD (Test-Driven Development)

Write tests first. Every new feature or bug fix must start with a failing test.

1. Write a failing test that defines the expected behavior
2. Write the minimum code to make the test pass
3. Refactor while keeping tests green

### POP (Protocol-Oriented Programming)

Favor protocols over inheritance. Data structures should conform to relevant Swift protocols:

- `Sequence` and `Collection` where applicable
- `Equatable`, `Hashable`, `Codable` when appropriate
- `Sendable` for thread-safety guarantees

### SOLID Principles

- **S**ingle Responsibility: Each type has one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for their base types
- **I**nterface Segregation: Prefer small, focused protocols
- **D**ependency Inversion: Depend on abstractions, not concretions

### Clean Code

- Meaningful, intention-revealing names
- Small, focused functions (ideally < 20 lines)
- No comments to explain bad code — rewrite the code instead
- Self-documenting code with clear abstractions

### DRY (Don't Repeat Yourself)

Extract common patterns into shared utilities or protocol extensions. Avoid copy-paste code.

### KISS (Keep It Simple, Stupid)

Choose the simplest solution that works. Avoid over-engineering and premature abstraction.

### YAGNI (You Aren't Gonna Need It)

Don't add functionality until it's actually needed. No speculative features.

### Fail Fast

Validate inputs early. Use `precondition` for programmer errors and throw errors for recoverable failures. Never silently ignore invalid states.

## Pull Request Process

1. **Create an ADR (Architecture Decision Record)** for new data structures before implementation, covering:
   - Copy semantics (value type with COW vs reference type)
   - ABI stability considerations
   - Performance characteristics and complexity guarantees

2. **Ensure all tests pass** with `swift test`

3. **Update documentation** for any public API changes

4. **Follow the commit message convention**:
   ```
   type(scope): description
   
   [optional body]
   ```
   Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

5. **Request review** from maintainers

6. **Address feedback** promptly and constructively

## Coding Standards

### Swift Style

- Use Swift's official API Design Guidelines
- 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Use `// MARK: -` to organize code sections

### Naming Conventions

- Types: `UpperCamelCase`
- Functions, properties, variables: `lowerCamelCase`
- Protocols describing capabilities: `-able`, `-ible`, or `-ing` suffix
- Acronyms: uppercase when alone (`HTTP`), lowercase in compounds (`httpRequest`)

### Access Control

- Default to `private` or `internal`
- Only expose `public` API that is intentional and documented
- Use `@usableFromInline internal` for performance-critical inlinable code

### Performance

- Document time and space complexity with `/// - Complexity: O(...)` 
- Prefer `O(1)` operations where possible
- Use Copy-on-Write for value types with heap storage
- Profile before optimizing

## Testing Requirements

We use **Swift Testing** framework exclusively.

### Test Structure

```swift
@Suite("DataStructure Tests")
struct DataStructureTests {
    
    @Test("initialization creates empty structure")
    func initialization() {
        // Arrange, Act, Assert
    }
    
    @Suite("insertion operations")
    struct InsertionTests {
        @Test("insert adds element")
        func insertAddsElement() { }
    }
}
```

### Coverage Expectations

- Minimum 90% code coverage for new code
- All public API must have tests
- Include edge cases: empty collections, single element, large datasets
- Test both success and failure paths

### Test Naming

Use descriptive test names that explain the expected behavior, not the implementation.

## Documentation

### Public API Documentation

Every public symbol must have documentation comments:

```swift
/// A last-in, first-out (LIFO) collection.
///
/// Use a stack when you need to access elements in reverse order of insertion.
///
/// - Complexity: Push and pop operations are O(1).
///
/// ## Example
///
/// ```swift
/// var stack = Stack<Int>()
/// stack.push(1)
/// stack.push(2)
/// print(stack.pop()) // Optional(2)
/// ```
public struct Stack<Element> { }
```

### Required Documentation Sections

- Brief description
- Detailed explanation (when needed)
- Complexity annotations for all operations
- Usage examples for non-trivial APIs
- Parameter and return value descriptions

## Questions?

Feel free to open an issue for questions or discussions about potential contributions.

Thank you for helping make DataStructuresKit better!
