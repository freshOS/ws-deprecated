![ws](https://raw.githubusercontent.com/freshOS/ws/master/banner.png)

# ws

[![Language: Swift 2 and 3](https://img.shields.io/badge/language-swift2|3-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods compatible](https://img.shields.io/badge/Cocoapods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/ws/blob/master/LICENSE)
[![Build Status](https://www.bitrise.io/app/a6d157138f9ee86d.svg?token=W7-x9K5U976xiFrI8XqcJw)](https://www.bitrise.io/app/a6d157138f9ee86d)
[![Release version](https://img.shields.io/badge/release-2.0-blue.svg)]()

[Reason](#why) - [Example](#usage) - [Installation](#installation)

```swift
let ws = WS("http://jsonplaceholder.typicode.com")

ws.get("/users").then { json in
    // Get back some json \o/
}
```

## Swift Version
Swift 2 -> version **1.3.0** ios8+  
Swift 3 -> version **2.0.0** ios9+


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

### Bare JSON

```swift
import ws // Import ws at the top of your file
import Arrow // Import Arrow to get access to the JSON type

class ViewController: UIViewController {

    // Set webservice base URL
    let ws = WS("http://jsonplaceholder.typicode.com")

    override func viewDidLoad() {
        super.viewDidLoad()

       // Get back some json instantly \o/
       ws.get("/users").then { (json:JSON) in
           print(json)
       }
    }
}
```

### Set up Model parsing
Create a `User+JSON.swift` file and map the JSON keys to your model properties
```swift
import Arrow

extension User: ArrowParsable {

    mutating func deserialize(_ json: JSON) {
        identifier <-- json["id"]
        username <-- json["username"]
        email <-- json["email"]
    }
}
```
*Note: `ws` uses `Arrow` for JSON Parsing
https://github.com/freshOS/Arrow*

### Choose what you want back

Here you are going to create a function that wraps your request.
There are different ways of writing that function depending on what you want back. An empty block, the JSON, the model or the array of models.

```swift
func voidCall() -> Promise<Void> {
    return ws.get("/users")
}

func jsonCall() -> Promise<JSON> {
    return ws.get("/users")
}

func singleModelCall() -> Promise<User> {
    return ws.get("/users/3")
}

func modelArrayCall() -> Promise<[User]> {
    return ws.get("/users")
}
```
As you can notice, only by changing the return type,
ws *automatically* knows what to do, for instance, try to parse the response into `User` models.

This enables us to stay concise without having to write extra code. \o/

*Note: `ws` uses `then` for Promises
https://github.com/freshOS/then*

### Get it!

```swift
voidCall().then {
    print("done")
}

jsonCall().then { json in
    print(json)
}

singleModelCall().then { user in
    print(user) // Strongly typed User \o/
}

modelArrayCall().then { users in
    print(users) // Strongly typed [User] \o/
}
```

## Settings

Want to log all network calls and responses ?
```swift
ws.logLevels = .debug
```

Want to hide network activity indicator ?

```swift
ws.showsNetworkActivityIndicator = false
```

## Api Example
Here is a Typical CRUD example for Articles :

```swift
extension Article {

    static func list() -> Promise<[Article]> {
        return ws.get("/articles")
    }

    func save() -> Promise<Article> {
        return ws.post("/articles", params: ["name":name])
    }

    func fetch() -> Promise<Article> {
        return ws.get("/articles/\(id)")
    }

    func update() -> Promise<Void> {
        return ws.put("/articles/\(id)", params: ["name":name])
    }

    func delete() -> Promise<Void> {
        return ws.delete("/articles/\(id)")
    }

}
```

Here is how we use it in code :
```swift
// List Articles
Article.list().then { articles in

}

// Create Article
var newArticle = Article(name:"Cool story")
newArticle.save().then { createdArticle in

}

// Fetch Article
var existingArticle = Article(id:42)
existingArticle.fetch().then { fetchedArticle in

}

// Edit Article
existingArticle.name = "My new name"
existingArticle.update().then {

}

// Delete Article
existingArticle.delete().then {

}
```

## Bonus - Load More pattern

Very often we deal we lists and the ability to `load more` items.
Here we are going to see an example implementation of this pattern using `ws`.
This is not included because the logic itself depends on your backend implementation.
This will give you an example for you to roll out your own version.

### Implementation


```swift
import ws
import then
import Arrow


class LoadMoreRequest<T:ArrowParsable> {

    var limit = 12

    private var params = [String:Any]()
    private var offset = 0
    private var call: WSRequest!
    private var canLoadMore = true
    private var aCallback:((_ ts: [T]) -> [T])? = nil

    init(_ aCall: WSRequest) {
        call = aCall
    }

    func resetOffset() {
        offset = 0
        canLoadMore = true
    }

    func hasMoreItemsToload() -> Bool {
        return canLoadMore
    }

    func fetchNext() -> Promise<[T]> {
        params = call.params
        params["limit"] = limit
        params["offset"] = offset
        call.params = params
        offset += limit
        return call.fetch()
                .registerThen(parseModels)
                .resolveOnMainThread()
    }

    private func parseModels(_ json: JSON) -> [T] {
        let mapper = WSModelJSONParser<T>()
        let models = mapper.toModels(json)
        if models.count < limit {
            canLoadMore = false
        }
        return models
    }
}
```
As you can see, we have a strongly typed request.  
The limit is adjustable.  
It encapsulates a WSRequest.  
It handles the offset logic and also wether or not there are more items to load.

And that's all we need!

Now, this is how  we build a `LoadMoreRequest`

```swift
func loadMoreUsersRequest() -> LoadMoreRequest<User> {
    return LoadMoreRequest(ws.getRequest("/users"))
}
```

### Usage
And here is how we use it in our controllers :

```swift
class ViewController: UIViewController {

    // Get a request
    let request = api.loadMoreUsersRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        request.limit = 5 // Set a limit if needed
    }

    func refresh() {
      // Resets the request, usually plugged with
      // the pull to refresh feature of a tableview
      request.resetOffset()
    }

    func loadMore() {
      // Get the next round of users
      request.fetchNext().then { users in
          print(users)
      }
    }

    func shouldDisplayLoadMoreSpinner() -> Bool {
      // This asks the requests if there are more items to come
      // This is useful to know if we show the "load more" spinner
      return request.hasMoreItemsToload()
    }
}
```

Here you go you now have a simple way to deal with load more requests in your App 🎉


## Bonus - Simplifying restful routes usage

When working with a `RESTFUL` api, we can have fun and go a little further.

By introducing a `RestResource` protocol
```swift
public protocol RestResource {
    static func restName() -> String
    func restId() -> String
}
```
We can have a function that builds our `REST` URL
```swift
public func restURL<T:RestResource>(_ r:T) -> String {
    return "/\(T.restName())/\(r.restId())"
}
```

We conform our `User` Model to the protocol
```swift
extension User:RestResource {
    static func restName() -> String { return "users" }
    func restId() -> String { return "\(identifier)" }
}
```


And we can implement a version of `get` that takes our a `RestResource`

```swift
public func get<T:ArrowParsable & RestResource>(_ restResource:T, params:[String:Any] = [String:Any]()) -> Promise<T> {               
    return get(restURL(restResource), params: params)
}
```
then

```swift
ws.get("/users/\(user.identifier)")
```
Can be written like :
```swift
ws.get(user)
```
Of course, the same logic can be applied to the all the other ws functions (`post`, `put` `delete` etc) ! 🎉
## Installation

### Carthage
In your Cartfile
```
github "freshOS/ws"
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

### Manually

Carthage is pretty useful since it takes care of pulling dependencies such as Arrow, then and Alamofire.
What's cool is that it really is transparent. What I mean is that you could just use carthage on the side to pull and build dependencies and manually link frameworks to your Xcode project.

Without Carthage, I'd see 2 solutions :
1 - Copy paste all the source code : ws / then / Arrow / Alamofire which doesn't sound like a lot of fun ;)
2 - Manually link the frameworks (ws + dependencies) by A grabbing .frameworks them on each repo, or B use Carthage to build them

### Cocoapods

```
target 'MyApp'
pod 'ws'
use_frameworks!
```

And voila !

## Other repos ❤️
ws is part of a series of lightweight libraries aiming to make developing iOS Apps a *breeze* :
- Async code : [then](https://github.com/freshOS/then)
- Layout : [Stevia](https://github.com/s4cha/Stevia)
- JSON Parsing : [Arrow](https://github.com/freshOS/Arrow)
