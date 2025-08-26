# Inject

Inject is a Swift dependency injection library designed for simplicity and clarity, offering a balance of capability and ergonomic usage. It avoids property wrappers to prevent mutable instance variables while providing a straightforward API for dependency resolution.

## Key Features

- **No property wrappers**: Injects dependencies directly via `Inject()` without requiring `@Inject` or mutable properties.
- **Singleton container with single scope**: Resolves dependencies once per representative type, with a single active scope (e.g., user session).
- **Explicit implementation mapping**: Each protocol maps to exactly one implementation, avoiding ambiguity.

## Getting Started

### Basic Usage

```swift
let coolManager = Inject(CoolManagerProtocol.self)
```

Or with type inference:

```swift
let coolManager: CoolManagerProtocol = Inject()
```

### Registering Dependencies

Register implementations in your app's setup:

```swift
InjectionManager.register(CoolManagerProtocol.self) { CoolManagerImpl() }
```

### Managing Scope

Reset the container for user sessions:

```swift
InjectionManager.resetCurrentContainer()
InjectionManager.register(UserSession.self) { UserSession(user: currentUser) }
```

## Design Philosophy

Inject prioritizes clarity and maintainability over advanced features. It enforces:

1. **Single implementation per protocol**: Ensures predictable dependency resolution.
2. **No arbitrary scopes**: Simplifies lifecycle management with a single active scope.

## Automation (Optional)

Dependency registration can be automated using [Velocity](https://github.com/jmfieldman/Velocity), a separate Swift package.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
