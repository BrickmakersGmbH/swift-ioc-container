# swift-ioc-container


[![Actions Status](https://github.com/BrickmakersGmbH/swift-ioc-container/workflows/Swift/badge.svg)](https://github.com/BrickmakersGmbH/swift-ioc-container/actions)


```swift
import swift_ioc_container

protocol ICanBeResolvedProtocol {
     func sayHello()
}
class CanBeResolved: ICanBeResolvedProtocol {
    
    static func register() {
        IoC.registerLazySingleton(ICanBeResolvedProtocol.self){ CanBeResolved() }
    }
    
    static func resolve() -> ICanBeResolvedProtocol {
        return try! IoC.resolve()
    }

    
    func sayHello() {
        print ("hello :)")
    }
}
```
And use it like this:

```swift
CanBeResolved.register() // Only needed once.

let resolvedInstance = CanBeResolved.resolve()
resolvedInstance.sayHello()
```

<!--
[![CI Status](https://img.shields.io/travis/Jonas Österle/brickmakers-ioc.svg?style=flat)](https://travis-ci.org/Jonas Österle/brickmakers-ioc)
[![Version](https://img.shields.io/cocoapods/v/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![License](https://img.shields.io/cocoapods/l/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![Platform](https://img.shields.io/cocoapods/p/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
-->

## Requirements

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
