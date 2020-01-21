# swift-ioc-container

```swift
import swift_ioc_container

protocol SuperAwesomeBot {
    func saySomething()
}

class StarWarsBot: SuperAwesomeBot {
    func saySomething() {
        print("The Force will be with you. Always.")
    }
}
```
And use it like this:

```swift
// only needed once
IoC.shared.registerLazySingleton(SuperAwesomeBot.self, { StarWarsBot() }) 


let myBot: SuperAwesomeBot = try! IoC.shared.resolve()
myBot.saySomething()
```


## Swift 5.1
If you are using Swift 5.1 or newer, you could take advantage of the new property wrapper feature.

```swift
@propertyWrapper
public struct Injected<Value> {
    
    public var wrappedValue: Value {
        try! IoC.shared.resolve()
    }
    
    public init() {}
}

@Injected private var myBot: SuperAwesomeBot
```
There is no more need to initialize the property manually in the initializer. Just declare the property with the expected protocoltype.


<!--
[![CI Status](https://img.shields.io/travis/Jonas Österle/brickmakers-ioc.svg?style=flat)](https://travis-ci.org/Jonas Österle/brickmakers-ioc)
[![Version](https://img.shields.io/cocoapods/v/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![License](https://img.shields.io/cocoapods/l/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![Platform](https://img.shields.io/cocoapods/p/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
-->

## Requirements
There are no further requirements beside Swift 5.0, just copy this little lib in your project and start.

## Installation

swift_ioc_container is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'swift_ioc_container'
```

## Authors

Michael Scherbakow, michael.scherbakow@brickmakers.de  
Jonas Österle, jonas.oesterle@brickmakers.de  
Pascal Friedrich, pascal.friedrich@brickmakers.de  
Philipp Manstein, philipp.manstein@brickmakers.de  

## License

swift_ioc_container is available under the MIT license. See the LICENSE file for more info.
