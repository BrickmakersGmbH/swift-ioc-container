import Foundation

public final class IoC {
    
    public static let shared = IoC()
    
    private init() {}
    
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    private var lazySingletons: [ObjectIdentifier: ()->AnyObject] = [:]
    private var typeConstructs: [ObjectIdentifier: ()->AnyObject] = [:]
    
    private var queues: [ObjectIdentifier: DispatchQueue] = [:]
    private let generalQueue = DispatchQueue(label: "ThreadSafe.Concurrent.Queue", qos: .background, attributes: .concurrent)
    
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
        let currentQueue: DispatchQueue = getDispatchQueue(id)
        
        if isTypeLazy(id: id) {
            convertLazyToSingleton(withQueue: currentQueue, forId: id)
        }
        
        guard let singleton = try getSingleton(id, forInterface: interface, withQueue: currentQueue) else {
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
    
    private func isTypeLazy(id: ObjectIdentifier) -> Bool {
        return generalQueue.sync {
            return lazySingletons.contains(where: { $0.key == id })
        }
    }
    
    private func getSingletonFromLazy(id: ObjectIdentifier) -> (() -> AnyObject)? {
        return lazySingletons.removeValue(forKey: id)
    }
    
    private func addSingletonToList(_ singleton: (()->AnyObject), forId id: ObjectIdentifier) {
        singletons[id] = singleton()
    }
    
    private func convertLazyToSingleton(withQueue queue: DispatchQueue, forId id: ObjectIdentifier) {
        queue.sync(flags: .barrier) {
            if self.isTypeLazy(id: id) {
                if let singleton = self.getSingletonFromLazy(id: id) {
                    self.addSingletonToList(singleton, forId: id)
                }
            }
        }
    }
    
    private func getSingleton<T>(_ id: ObjectIdentifier, forInterface interface: T.Type, withQueue queue: DispatchQueue) throws -> T? {
        var ret: T? = nil
        try queue.sync {
            if let singleton = singletons[id] {
                guard let typedSingleton = singleton as? T else {
                    throw IoCError.incompatibleTypes(interfaceType: interface, implementationType: type(of: singleton))
                }
                
                ret = typedSingleton
            }
        }
        return ret
    }
    
    private func getDispatchQueue(_ id: ObjectIdentifier) -> DispatchQueue {
        if existsQueue(forId: id) {
            return getQueue(forId: id)
        } else {
            return createQueue(forId: id)
        }
    }
    
    private func existsQueue(forId id: ObjectIdentifier) -> Bool {
        return generalQueue.sync {
            return  queues.contains(where: { $0.key == id })
        }
    }
    
    private func getQueue(forId id: ObjectIdentifier) -> DispatchQueue {
        return generalQueue.sync {
            return queues.first(where: { $0.key == id})!.value
        }
    }
    
    private func createQueue(forId id: ObjectIdentifier) -> DispatchQueue {
        generalQueue.sync(flags: .barrier) {
            self.queues[id] = DispatchQueue(label: "\(id.debugDescription)")
        }
        return queues[id]!
    }
}

enum IoCError: Error {
    case nothingRegisteredForType(typeIdentifier: Any.Type)
    case incompatibleTypes(interfaceType: Any.Type, implementationType: Any.Type)
}
