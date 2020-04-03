public final class IoC {
    
    public static let shared = IoC()
    
    private init() {}
    
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    private var lazySingletons: [ObjectIdentifier: ()->AnyObject] = [:]
    private var typeConstructs: [ObjectIdentifier: ()->AnyObject] = [:]
    
    public func registerSingleton<T>(_ interface: T.Type, _ instance: AnyObject) throws {
        guard instance is T else {
            throw IoCError.incompatibleTypes(interfaceType:interface, implementationType:type(of: instance))
        }
        singletons[ObjectIdentifier(interface)] = instance
        lazySingletons.removeValue(forKey: ObjectIdentifier(interface))
    }
    
    public func registerLazySingleton<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        lazySingletons[ObjectIdentifier(interface)] = construct
    }
    
    public func registerType<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        typeConstructs[ObjectIdentifier(interface)] = construct
    }
    
    public func resolve<T>() throws -> T {
        return try resolve(T.self)
    }
    
    public func resolve<T>(_ interface: T.Type) throws -> T {
        let id = ObjectIdentifier(interface)
        
        if let typeConstruct = typeConstructs[id] {
            let instance = typeConstruct()
            guard let typedInstance = instance as? T else {
                throw IoCError.incompatibleTypes(interfaceType: interface, implementationType: type(of: instance))
            }
            
            return typedInstance
        }
        
        if let lazyValue = lazySingletons.removeValue(forKey: id) {
            singletons[id] = lazyValue()
        }
        
        if let singleton = singletons[id] {
            guard let typedSingleton = singleton as? T else {
                throw IoCError.incompatibleTypes(interfaceType: interface, implementationType: type(of: singleton))
            }
            
            return typedSingleton
        }
        
        throw IoCError.nothingRegisteredForType(typeIdentifier: interface)
    }
    
    public func resolveOrNil<T>(_ interface: T.Type) -> T? {
        do {
            return try resolve(interface)
        } catch {
            return nil
        }
    }
    
    public func resolveOrNil<T>() -> T? {
        return resolveOrNil(T.self)
    }
    
    /// Use this function only to see, if all your constructors are able to be initialized.
    public func validateRegisteredConstructors(blackList: [ObjectIdentifier] = []) {

        for lazy in lazySingletons {
            if !blackList.contains(lazy.key) {
                debugPrint(lazy.key)
                _ = lazy.value()
            }

        }
    }
    
    public func unregisterAll() {
        singletons.removeAll()
        lazySingletons.removeAll()
        typeConstructs.removeAll()
    }
}

enum IoCError: Error {
    case nothingRegisteredForType(typeIdentifier: Any.Type)
    case incompatibleTypes(interfaceType: Any.Type, implementationType: Any.Type)
    case canNotConstruct
}
