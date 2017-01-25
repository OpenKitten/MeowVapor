import MeowVapor
import Vapor
import HTTP

let drop = Droplet()

drop.middleware = []

drop.get("users", User.self) { _, user in
    return user
}

try! drop.start("monxxgodb://localhost/kaas")
