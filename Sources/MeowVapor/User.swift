import Turnstile

public protocol User: Model, Account, Authenticator { }

public protocol Authenticator {
    static func authenticate(credentials: Credentials) throws -> User
    static func register(credentials: Credentials) throws -> User
}
