public final class IoC {
    private static var singletons: [ObjectIdentifier: AnyObject] = [:]
    private static var lazySingletons: [ObjectIdentifier: ()->AnyObject] = [:]
    private static var typeConstructs: [ObjectIdentifier: ()->AnyObject] = [:]
    
    public static func registerSingleton<T>(_ interface: T.Type, _ instance: AnyObject) throws {
        guard instance is T else {
            throw IoCError.incompatibleTypes(interfaceType:interface, implementationType:type(of: instance))
        }
        singletons[ObjectIdentifier(interface)] = instance
        lazySingletons.removeValue(forKey: ObjectIdentifier(interface))
    }
    
    public static func registerLazySingleton<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        lazySingletons[ObjectIdentifier(interface)] = construct
    }
    
    public static func registerType<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        typeConstructs[ObjectIdentifier(interface)] = construct
    }
    
    public static func resolve<T>() throws -> T {
        return try resolve(T.self)
    }
    
    public static func resolve<T>(_ interface: T.Type) throws -> T {
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
    
    public static func resolveOrNil<T>(_ interface: T.Type) -> T? {
        do {
            return try resolve(interface)
        } catch {
            return nil
        }
    }
    
    public static func resolveOrNil<T>() -> T? {
        return resolveOrNil(T.self)
    }
    
    public static func unregisterAll() {
        singletons.removeAll()
        lazySingletons.removeAll()
        typeConstructs.removeAll()
    }
}

enum IoCError: Error {
    case nothingRegisteredForType(typeIdentifier: Any.Type)
    case incompatibleTypes(interfaceType: Any.Type, implementationType: Any.Type)
}
