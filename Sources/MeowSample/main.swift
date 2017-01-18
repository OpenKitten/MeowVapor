import MeowVapor
import Vapor
import MeowVaporTemplating
import BSONTemplating
import HTTP

let drop = Droplet()

let stem = MeowVaporTemplating.Stem(workingDirectory: "/Users/joannis/Desktop/")

drop.get("remove") { _ in
    try Meow.database.drop()
    
    return Response(status: .ok)
}

drop.get("populate") { req in
    for _ in 0..<1000 {
        _ = try Meow.database["users"].insert([
            "hoi": "kaas"
            ])
    }
    return Response(status: .ok)
}

//Hoi
//#loop(cursor, "user") {
//    #(user.hoi) 123
//}
//meep
drop.get("leaf") { req in
    let leaf = try stem.spawnLeaf(named: "kaas")
    
    let cursor = try Meow.database["users"].find(withBatchSize: 1000)
    
    return Response(body: try stem.render(leaf, with: Context(["cursor": cursor] as Document)))
}

//Hoi
//#loop(cursor, "user") {
//    #(user.hoi) 123
//}
//meep
drop.get("bsontemplating") { req in
    let template = Template(compiled: [
    // hoi
        0x01, 0x68, 0x6f, 0x69, 0x0a, 0x00,
        // for user in cursor
            0x02, 0x02, 0x75, 0x73, 0x65, 0x72, 0x00, 0x01, 0x63, 0x75, 0x72, 0x73, 0x6f, 0x72, 0x00, 0x00,
            // print user.hoi
                0x02, 0x03, 0x01, 0x75, 0x73, 0x65, 0x72, 0x00, 0x68, 0x6f, 0x69, 0x00, 0x00,
                // " 123"
                0x01, 0x20, 0x31, 0x32, 0x33, 0x0a, 0x00,
            0x00,
        0x00,
        // meep
        0x01, 0x6d, 0x65, 0x65, 0x70,
        ])
    
    let result = try template.run(inContext: [
            "cursor": Template.Context.ContextValue.cursor(try Meow.database["users"].find(withBatchSize: 1000))
        ])
    
    return Response(body: .data(result))
}

try! drop.start("mongodb://localhost/kaas")
