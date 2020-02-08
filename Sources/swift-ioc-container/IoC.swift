import Foundation

public final class IoC {
    
    public static let shared = IoC()
    
    private init() {}
    
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    private var lazySingletons: [ObjectIdentifier: ThreadSafeBox<AnyObject>] = [:]
    private var typeConstructs: [ObjectIdentifier: ()->AnyObject] = [:]
    public func registerSingleton<T>(_ interface: T.Type, _ instance: AnyObject) throws {
        guard instance is T else {
            throw IoCError.incompatibleTypes(interfaceType:interface, implementationType:type(of: instance))
        }
        singletons[ObjectIdentifier(interface)] = instance
        lazySingletons.removeValue(forKey: ObjectIdentifier(interface))
    }
    
    public func registerLazySingleton<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        lazySingletons[ObjectIdentifier(interface)] = ThreadSafeBox(construct)
    }
    
    public func registerType<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject) {
        typeConstructs[ObjectIdentifier(interface)] = construct
    }
    
    public func resolve<T>() throws -> T {
        return try resolve(T.self)
    }
    
    public func resolve<T>(_ interface: T.Type) throws -> T {
        let id = ObjectIdentifier(interface)
        
        if let typeConstruct = try getTypeConstruct(id, forInterface: interface) {
            return typeConstruct
        }
        
        if let lazySingleton = try getLazySingleton(id, forInterface: interface) {
            return lazySingleton
        }
        
        guard let singleton = try getSingleton(id, forInterface: interface) else {
            throw IoCError.nothingRegisteredForType(typeIdentifier: interface)
        }
        
        return singleton
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
    
    public func unregisterAll() {
        singletons.removeAll()
        lazySingletons.removeAll()
        typeConstructs.removeAll()
    }
    

    private func getSingleton<T>(_ id: ObjectIdentifier, forInterface interface: T.Type) throws -> T? {
        if let singleton = self.singletons[id] {
            return try getTypedInstance(interface, instance: singleton)
        }
        return nil
    }
    
    private func getLazySingleton<T>(_ id: ObjectIdentifier, forInterface interface: T.Type) throws -> T? {
        if let lazySingleton = self.lazySingletons[id] {
            let lazySingletonObj = lazySingleton.read()
            return try getTypedInstance(interface, instance: lazySingletonObj)
        }
        return nil
    }
    
    private func getTypeConstruct<T>(_ id: ObjectIdentifier, forInterface interface: T.Type) throws -> T? {
        if let typeConstruct = self.typeConstructs[id] {
            let instance = typeConstruct()
            return try getTypedInstance(interface, instance: instance)
        }
        return nil
    }

    private func getTypedInstance<T>(_ interface: T.Type, instance: AnyObject) throws -> T {
        guard let typedInstance = instance as? T else {
            throw IoCError.incompatibleTypes(interfaceType: interface, implementationType: type(of: instance))
        }
        
        return typedInstance
    }
}

enum IoCError: Error {
    case nothingRegisteredForType(typeIdentifier: Any.Type)
    case incompatibleTypes(interfaceType: Any.Type, implementationType: Any.Type)
}
