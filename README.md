# ws ☁️ - *Elegant JSON WebService in Swift*


[![Language: Swift 2](https://img.shields.io/badge/language-swift2-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/s4cha/ws/blob/master/LICENSE)
[![Release version](https://img.shields.io/badge/release-1.1-blue.svg)]()

[Reason](#why) - [Example](#usage) - [Installation](#installation)

```swift
let ws = WS("http://jsonplaceholder.typicode.com")

ws.get("/users").then { json in
    // Get back some json \o/
}
```


## Why
Because JSON apis are used in **99% of iOS Apps**, this should be  **simple**.  
We developers should **focus on our app logic** rather than *boilerplate code* .  
*Less* code is *better* code

## How
By providing a lightweight client that **automates boilerplate code everyone has to write**.  
By exposing a **delightfully simple** api to get the job done simply, clearly, quickly.  
Getting swift models from a JSON api is now *a problem of the past*

## What
- [x] Simple
- [x] Lightweight (1 file)
- [x] Pure Swift
- [x] No magic involved
- [x] Strongly Typed
- [x] Chainable
- [x] Uses popular Promise/Future concept

## Usage

### Import ws at the top of your file

```swift
import ws
```

### Set webservice base URL

```swift
let ws = WS("http://jsonplaceholder.typicode.com")
```

### Get back some json instantly \o/
```swift
ws.get("/users").then { json in
    print(json)
}
```

### Design your Api

```swift
func latestUsers() -> Promise<[User]> {
    return ws.get("/users")
}
```

### Tell ws how to map your user models
```swift
extension User:ArrowParsable {
    init(json: JSON) {
        identifier <-- json["id"]
        username <-- json["username"]
        email <-- json["email"]
    }
}
```

### Get back some sweet swift models ❤️
```swift
latestUsers().then { users in
    print(users) // STRONGLY typed [Users] ❤️
}

```


## Installation

### Carthage
In your Cartfile
```
github "s4cha/ws"
```
- Run `carthage update`
- Drag and drop `ws.framework` from `Carthage/Build/iOS` to `Linked Frameworks and Libraries` (“General” settings tab)
- Go to  `Project` > `Target` > `Build Phases` + `New run Script Phase`

`/usr/local/bin/carthage copy-frameworks`

Add input files
```
$(SRCROOT)/Carthage/Build/iOS/ws.framework
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
$(SRCROOT)/Carthage/Build/iOS/Arrow.framework
$(SRCROOT)/Carthage/Build/iOS/then.framework
```

This links ws and its dependencies.

And voila !

## Other repos ❤️
ws is part of a series of lightweight libraries aiming to make developing iOS Apps a *breeze* :
- Async code : [then](https://github.com/s4cha/then)
- Layout : [Stevia](https://github.com/s4cha/Stevia)
- JSON Parsing : [Arrow](https://github.com/s4cha/Arrow)
