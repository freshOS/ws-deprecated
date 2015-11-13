# ws
Lightweight JSON WebService maganer in swift



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
$(SRCROOT)/Carthage/Build/iOS/Arrow.framework
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
```

This links ws and its dependencies.

And voila !


## Usage

```swift
import ws // import ws at the top of your file


// Set webservice base URL
let ws = WS("http://jsonplaceholder.typicode.com")

// Get back some json \o/
ws.call("/users").then { json in
    print(json)
}
```

 Want to automatically parse JSON to your nice Swift models??


```swift
// Get back some sweet swift models <3
let latestUsersCall:Promise<[User]> = ws.resourcesCall(url: "/users")
latestUsersCall.succeeds { users in
    print(users) // users is STRONGLY typed <3
}

```
