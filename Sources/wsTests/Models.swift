//
//  File.swift
//  
//
//  Created by Sacha DSO on 28/01/2020.
//

import Foundation

struct Article {
    var id: Int = 0
    var name: String = ""
}

// MARK: - Models

struct User {
    var identifier = 0
    var username = ""
    var email = ""
    var name = ""
    var phone = ""
    var website: NSURL?
    var company = Company()
    var address = Address()
}

//todo Does not work when useing forced !

struct Company {
    var bs = ""
    var catchPhrase = ""
    var name = ""
}

struct Address {
    var city = ""
    var street = ""
    var suite = ""
    var zipcode = ""
    var geo = Geo()
}

struct Geo {
    var lat = ""
    var lng = ""
}

enum FooBar: String {
    case foo = "Foo"
    case bar = "Bar"
}
