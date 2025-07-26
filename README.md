# Injection

This is a Swift dependency injection library that provides the opinionatedly-correct balance of capability vs. ergonomics.

When setup correctly, you can inject dependencies into your classes using the following syntax options:

```swift
class MyClass {

    // You can opt to pass the required type explicitly into Inject()
    let coolManager = Inject(CoolManagerProtocol.self)

    // Or let the parameter be inferred
    let coolManager: CoolManagerProtocol = Inject()
}
```

Note the lack of property wrappers, like `@Inject`, which would require the instance to be declared with `var`. It's just not worth the fancy syntax at the cost of preventing immutable ivars.

### Core Principles

The core principles of this library are:

1. A representative type should only ever map to a single implementation type.
2. The singleton container has one layer of scope (typically the logged-in user)

#### Core Principal #1: Singleton Container

Inject uses a global map to store:

* A map of type -> resolution block
* A map of type -> resolved instances

When `Inject` is called, it returns the previously resolved instance, or generates a new one with the resolution block and stores it for future use.

This means you can only have one instance returned for the corresponding representative type. Typically this plays out as Protocol -> Instance, e.g. 

```swift
protocol CoolManager { ... }
class CoolManagerImpl: CoolManager { ... }

InjectionManager.register(CoolManager.self) { CoolManagerImpl() }
```

If your codebase has a consistent naming convention for Protocol -> Implementation, it will always be straightforward to find the exact implementation of the instance your code will use.

It is a code-readability nightmare when an injection framework allows parameterized injection, or is not clear on exactly which implementation is emitted for a protocol.

If your use case requires some kind of parameterized result, that should be an explicit implementation detail of the protocol/instance you are resolving (e.g. the manager would have its own functions to vend some other object based on input parameters.)

```swift
// This is good
let configManager: ConfigManager = Inject()
let config = configManager.configFor(params: configParams)

// This is bad
let config = Inject(Config.self, /* Some kind of parameterization */)
```

#### Core Principal #2: Single Scope

Some dependency injection frameworks allow for arbitrary scope layers. That is, you can have singletons resolved at a global level, and then have arbitrarily smaller scopes for more specific activities. In these cases, the lifetime of the resolved instances lives with the activity.

It is the opinion of this library that arbitrary scopes does not provide a positive cost-benefit value, and always become a nightmare to maintain, understand, and debug. It may be valuable to *massive* codebases, but is overkill for most apps.

With Inject, there is only one active scope at any given time. You can choose what this scope represents. 

For simple apps without user login, you may never need to think about this at all.

For apps with user logic, you will typical reset the scope when a user logs in:

```swift
// During login/logout:
InjectionManager.resetCurrentContainer()

// Set a foundational scope value that represents the user session
InjectionManager.register(UserSession.self) { UserSession(user: ...) }
```

This evicts all resolved instances, and replaces some foundational type with the new user session information. When future instances are re-resolved, they will also inject that new session instance.

Ensure that this is done before instantiating any new flow that is dependent on that new foundational instance.

### Automating Resolution Registration

Your app will likely have a lot of protocols and implementations. You can automate the creation of your instance registration using [Velocity](https://github.com/jmfieldman/Velocity).
