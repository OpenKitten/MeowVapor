# Setup

From the terminal:

```bash
# Create the project directory
mkdir MyApplicationName
cd MyApplicationName

# Create an application (for websites)
swift package init --type=executable

# Edit the Package.swift to add the dependency on VaporMeow ( https://github.com/OpenKitten/MeowVaporExample/blob/master/Package.swift )
open Package.swift

# Create an empty generated file for Xcode
touch Sources/Generated.swift

# Create an xcode project
swift package generate-xcodeproj
```

# Models

First you'll have to create/edit your models. They need to be a class. They only require 2 things:

- Need to be conforming to `Model`
- Need the variable `id` to be `ObjectId()`

This is the most basic model. It doesn't even require, initalizers, serialization or de-serialization

```swift
final class User : Model {
  var id = ObjectId()
}
```

From here you can create embeddable classes, enums and structs

```swift
enum Gender : String, Embeddable {
  case male, female
}
```

```swift
struct Contact : Embeddable {
  var skype: String
  var email: String
  var website: String
}
```

And you can use those in models, too:

```swift
final class User : Model {
  var id = ObjectId()
  var gender: Gender?
  var contact: Contact?
  var firstName: String
  var lastName: String

  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
}
```

If you want to make routes in Vapor:
```swift
let drop = Droplet()

// Returns the user as extendedJSON
drop.get("users", User.self) { request, user in
  return user
}

drop.get("users") { _ in
  return try User.find()
}

// NOT drop.run(), this MongoDB URL is for you to change
drop.start("mongodb://localhost:27017/mydatabase")
```

Type-safe queries to match type-safe routes!

```swift
let userJoannis = try User.findOne { user in
  return user.firstName == "Joannis" && user.lastName == "Orlandos"
}
```

Support for relationships (even one-to-many) is intuitive:

```swift
final class Group : Model {
  var id = ObjectId()
  var owner: Reference<User, Ignore>
  var members: [Reference<User, Ignore>] = []
  var name: String

  init(named name: String, owner: Reference<User, Ignore>) {
    self.owner = owner
  }
}

let group = try Group.findOne { group in
  return group.owner == userJoannis && group.name.contains("swift") && !group.name.contains("PHP")
}
```

Resolving references:

```swift
let owner = try group.owner.resolve()
```

# Every model creation/update

```bash
# This will update the boilerplate and type-safe queries code
sourcery Sources Packages/MeowVapor-*/Templates Sources/Generated.swift
```