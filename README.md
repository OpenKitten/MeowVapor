# 🐈 MeowVapor

MeowVapor bridges [Meow](https://github.com/openkitten/meow) to Vapor and provides awesome helpers for creating a Meow based Vapor app/API.

### Add the dependency

```swift
.package(url: "https://github.com/OpenKitten/MeowVapor.git", from: "2.0.0")
```

## Setting up

Add Meow to your Vapor services. Be sure to change the MongoDB URI to point to your server.

```swift
let meow = try MeowProvider("mongodb://ocalhost")
try services.register(meow)
```

## Using MeowVapor

```swift
router.get { request -> Future<[User]> in
   return request.meow().flatMap { context in
      // Start using Meow!
      return context.find(User.self).getAllResults()
   }
}
```

### Installation

Add MeowVapor as a dependency via SPM and run `swift package update`.
