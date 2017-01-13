import HTTP
import Flow
import Vapor
import FlowTemplating

let drop = Droplet()
try Meow.init("mongodb://localhost/kaas")

let stem = FlowTemplating.Stem(workingDirectory: "/Users/joannis/Desktop/")


drop.get("populate") { req in
    for _ in 0..<1000 {
        _ = try Meow.database["users"].insert([
            "hoi": 3
            ])
    }
    return Response(status: .ok)
}

drop.get("hoi") { req in
    let leaf = try stem.spawnLeaf(named: "kaas")
    
    let cursor = try Meow.database["users"].find()
    
    return Response(body: try stem.render(leaf, with: Context(["cursor": cursor] as Document)))
}

try! drop.start("mongodb://localhost/kaas")
