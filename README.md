# swift-ioc-container


[![Actions Status](https://github.com/BrickmakersGmbH/swift-ioc-container/workflows/UnitTests_on_Master/badge.svg)](https://github.com/BrickmakersGmbH/swift-ioc-container/actions)
[![Actions Status](https://github.com/BrickmakersGmbH/swift-ioc-container/workflows/UnitTests_on_develop/badge.svg)](https://github.com/BrickmakersGmbH/swift-ioc-container/actions)


```swift
import Swift_IoC_Container

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

If you are using Swift 5.1 or newer, you could take advantage of the new property wrapper feature. It's already implemented in this library.

There is no more need to initialize the property manually in the initializer. Just declare the property with the expected protocol type.

```swift
@Injected private var myBot: SuperAwesomeBot
```

After declaring the property as `@Injected` you can access the previously registered object as you are used to.

An example implementation can be found in Example.swift

<!--
[![CI Status](https://img.shields.io/travis/Jonas Österle/brickmakers-ioc.svg?style=flat)](https://travis-ci.org/Jonas Österle/brickmakers-ioc)
[![Version](https://img.shields.io/cocoapods/v/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![License](https://img.shields.io/cocoapods/l/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
[![Platform](https://img.shields.io/cocoapods/p/brickmakers-ioc.svg?style=flat)](https://cocoapods.org/pods/brickmakers-ioc)
-->

## Requirements
There are no further requirements beside Swift 5.1, just copy this little lib in your project and start.

## Installation

swift_ioc_container is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Swift-IOC-Container'
```

## Authors

Michael Scherbakow, michael.scherbakow@brickmakers.de  
Jonas Österle, jonas.oesterle@brickmakers.de  
Pascal Friedrich, pascal.friedrich@brickmakers.de  
Philipp Manstein, philipp.manstein@brickmakers.de  

## License

Swift_IoC_Container is available under the MIT license. See the LICENSE file for more info.
