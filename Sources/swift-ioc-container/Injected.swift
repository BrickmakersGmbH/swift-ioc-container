#if swift(>=5.1)  // check for swift 5.1 and later

@propertyWrapper
public struct Injected<Value> {
    
    public var wrappedValue: Value {
        try! IoC.shared.resolve()
    }
    
    public init() {}
}

#endif
