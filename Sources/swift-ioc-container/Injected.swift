@propertyWrapper
public struct Injected<Value> {
    
    public var wrappedValue: Value {
        try! IoC.shared.resolve()
    }
    
    public init() {}
}
