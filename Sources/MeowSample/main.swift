import MeowVapor
import Vapor
import MeowVaporTemplating
import BSONTemplating
import HTTP

let drop = Droplet()

drop.middleware = []

drop.get("users", User.self) { _, user in
    return user
}

try! drop.start("mongodb://localhost/kaas")
