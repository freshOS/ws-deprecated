//
//  Pormise.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/15.
//  Copyright © 2015 s4cha. All rights reserved.
//

import Foundation

enum PromiseState {
    case Pending
    case Fulfilled
    case Rejected
}

public enum WSError:ErrorType {
    case DefaultError
    case NetworkError
}

public class Promise<T> {
    
    private var state:PromiseState = .Pending
    private var value:T?
    //    private var error:String?
    private var error:ErrorType? //TODO try with error type instead
    
    var successBlock:(object:T) -> Void = { t in }
    //    var failBlock:((error:String) -> Void) = { err in }
    var failBlock:((error:ErrorType) -> Void) = { err in }
    var finallyBlock:() -> Void = { t in }
    init() {}
    
    typealias ResolveCallBack = (object:T) -> Void
    typealias RejectCallBack = (err:ErrorType) -> Void
    //    typealias RejectCallBack = (err:String) -> Void
    
    init(callback:(resolve:ResolveCallBack, reject:RejectCallBack) -> Void) {
        callback(resolve: { (object) -> Void in
            self.state = .Fulfilled
            self.value = object
            self.successBlock(object: object)
            self.finallyBlock()
            }) { (err:ErrorType) -> Void in
                self.state = .Rejected
                self.error = err
                self.failBlock(error: self.error!)
                self.finallyBlock()
        }
    }
    
    public func then<X>(block:(result:T) -> X) -> Promise<X>{
        return Promise<X>(callback: { (resolve, reject) -> Void in
            
            if self.state == .Fulfilled {
                print(self.value!)
                let x:X = block(result: self.value!)
                resolve(object:x)
            } else if self.state == .Rejected {
                
                reject(err:self.error!)
                //                self.failBlock(error: self.error!)
            } else {
                self.successBlock = { t in
                    resolve(object:block(result: t))
                }
            }
            
            self.failBlock = { err in
                reject(err:err)
            }
        })
    }
    
    
    public func succeeds(block:(t:T) -> Void) -> Self {
        if state == .Fulfilled {
            block(t: value!)
        } else {
            successBlock = block
        }
        return self
    }
    
    public func emptySucceeds(emptyBlock:() -> Void) -> Self  {
        successBlock = { t in
            emptyBlock()
        }
        return self
    }
    
    public func fails(block:() -> Void) -> Self  {
        if state == .Rejected {
            block()
        } else {
            failBlock = { err in
                block()
            }
        }
        return self
    }
    
    public func fails(block:(error:ErrorType) -> Void) -> Self  {
        if state == .Rejected {
            block(error: error!)
        } else {
            failBlock = { err in
                block(error: err)
            }
        }
        return self
    }
    
    public func finally(block:() -> Void) -> Self  {
        if state != .Pending {
            block()
        } else {
            finallyBlock = block
        }
        return self
    }
}