public class IoC {
    fileprivate static var singletons:[String:AnyObject] = [String:AnyObject]()
    fileprivate static var lazySingletons:[String:()->AnyObject] = [:]
    fileprivate static var typeConstructs:[String:()->AnyObject] = [:]
    
    public static func registerSingleton<T>(_ interface: T.Type, _ instance: AnyObject) throws{
        if instance is T {
            singletons[String(describing: interface)] = instance
            lazySingletons.removeValue(forKey: String(describing: interface))
        }
        else {
            throw IoCError.incompatibleTypes(interfaceType:String(describing: interface), implementationType:String(describing: type(of: instance)))
        }
    }
    
    public static func registerLazySingleton<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject){
        lazySingletons[String(describing: interface)] = construct
    }
    
    public static func registerType<T>(_ interface: T.Type, _ construct: @escaping ()->AnyObject){
        typeConstructs[String(describing: interface)] = construct
    }
    
    public static func resolve<T>() throws -> T{
        return try resolve(T.self)
    }
    
    public static func resolve<T>(_ interface: T.Type) throws -> T{
        let id = String(describing: interface)
        
        if typeConstructs.contains(where: {(key:String, val:()->AnyObject) in key == id}){
            let instance = typeConstructs[id]!()
            if instance is T{
                return instance as! T
            }
            
            throw IoCError.incompatibleTypes(interfaceType: id, implementationType: String(describing: type(of: instance)))
        }
        
        if lazySingletons.contains(where: {(key:String, val:()->AnyObject) in key == id}){
            singletons[id] = lazySingletons.removeValue(forKey: id)!()
        }

        if singletons.contains(where: {(key:String, val:AnyObject) in key == id}){
            if singletons[id] is T {
                return singletons[id]! as! T
            }
            
            throw IoCError.incompatibleTypes(interfaceType: id, implementationType: String(describing: type(of: singletons[id])))
        }
        
        throw IoCError.nothingRegisteredForType(typeIdentifier: id)
    }
    
    public static func resolveOrNil<T>(_ interface: T.Type) -> T?{
        do{
            return try resolve(interface)
        }catch{
            return nil
        }
    }
    
    public static func resolveOrNil<T>() -> T?{
        return resolveOrNil(T.self)
    }
    
    public static func unregisterAll(){
        singletons.removeAll()
        lazySingletons.removeAll()
        typeConstructs.removeAll()
    }
}

enum IoCError : Error{
    case nothingRegisteredForType(typeIdentifier:String)
    case incompatibleTypes(interfaceType:String, implementationType:String)
}
