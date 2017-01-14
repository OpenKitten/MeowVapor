import MeowVapor
import Foundation

final class Tutorial: Model {
    var id = ObjectId()
    var name: String = ""
    var author: String = ""
    var medium: Medium = .article
    var image: String = ""
    var url: String = ""
    var description: String = ""
    var duration: Int = 0
    var difficulty: Difficulty = .easy
    var exists: Bool = false
    var l1_inverter_min_v_alert: Double?
    
    // sourcery: api=get,pathSuffix=/,permissions=anonymous
    static func list() throws -> Cursor<Tutorial> {
        return try Tutorial.find()
    }
    
    // sourcery: api=get,data=query,pathSuffix=filtered,permissions=anonymous
    static func list(minDuration: Int, maxDuration: Int) throws -> Cursor<Tutorial> {
        return try Tutorial.find { tutorial in
            return tutorial.duration >= minDuration && tutorial.duration <= maxDuration
        }
    }
    
    // sourcery: api=post,data=json,pathSuffix=/,permissions=anonymous
    static func create(name: String, author: String, url: String, image: String?) throws -> Tutorial {
        let tutorial = Tutorial(named: name, author: author, url: url, image: image)
        try tutorial.save()
        
        return tutorial
    }
    
    // sourcery: api=delete,pathSuffix=/,permissions=anonymous
    func remove() throws {
        try self.delete()
    }
    
    init(named name: String, author: String, url: String, image: String?) {
        self.name = name
        self.author = author
        self.url = url
        self.image = image ?? ""
    }
}

enum Difficulty: String, Embeddable {
    case easy, intermediate, advanced
}

enum Medium: String, Embeddable {
    case video, article
}
