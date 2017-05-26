import Foundation
import HTTP
import BSON

extension Binary : BodyRepresentable {
    public func makeBody() -> Body {
        return Body.data(Bytes(self.data))
    }
}

extension Binary : BytesConvertible {
    public init(bytes: Bytes) throws {
        self.data = Data(bytes)
        self.subtype = .generic
    }
    
    public func makeBytes() -> Bytes {
        return Bytes(self.data)
    }
}
