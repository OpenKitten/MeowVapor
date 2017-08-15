# 🐈 MeowVapor

MeowVapor bridges [Meow](https://github.com/openkitten/meow) to Vapor and provides awesome helpers for creating a Meow based Vapor app/API.

### Installation

Add MeowVapor as a dependency via SPM and run `swift package update`.

In your MeowConfig, specify: `plugins=("MeowVapor")`

### Minimal setup for basic CRUD

```swift
drop.resource("my-model", ModelController<MyModel>())
```

### Custom routes

```swift
class MyModelController : ModelController<MyModel> {
    func customRoute(request: Request) throws -> ResponseRepresentable {
    	let instance = try request.parameters.next(MyModel.self)
    	// ...
    }
}
```

```swift
let controller = MyModelController()
drop.resource("my-model", controller)
drop.get("my-model", MyModel.parameter, handler: controller.customRoute)
```

### Access control & authentication

Use `ClosureBasedAccessControlModelController`, or subclass `ModelController` and override the methods.