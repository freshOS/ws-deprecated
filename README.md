# ws [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
 <!-- [![Build Status](https://www.bitrise.io/app/a6d157138f9ee86d.svg?token=W7-x9K5U976xiFrI8XqcJw&branch=master)](https://www.bitrise.io/app/a6d157138f9ee86d) -->

Lightweight JSON WebService in swift

```swift
let ws = WS("http://jsonplaceholder.typicode.com")

// Get back some json \o/
ws.get("/users").then { json in
    print(json)
}
```

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
    return ws.list("/users")
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
```
github "s4cha/ws"
```
go to  `Project` > `Target` > `Build Phases` + `New run Script Phase`

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
