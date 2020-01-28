//
//  File.swift
//  
//
//  Created by Sacha DSO on 28/01/2020.
//

import Foundation
import Combine

public extension Publisher where Output == WSJSON, Failure == Error {
        
    func toVoid() -> AnyPublisher<Void, Error> {
        return self.map { _ in }.eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Error {

    func receiveOnMainThread() -> AnyPublisher<Output, Error> {
        return self.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
}


extension Publisher {
    
    @discardableResult
    func then(_ closure: @escaping (Output) -> Void) -> Self {
        var cancellable: AnyCancellable?
        cancellable = self.sink(receiveCompletion: { completion in
            cancellable = nil
        }) { value in
            closure(value)
        }
        return self
    }
    
    @discardableResult
    func onError(_ closure: @escaping (Failure) -> Void) -> Self {
//        self.catch { (e:Failure) -> AnyPublisher<Output, Failure> in
//            closure(e)
//            return self
//        }
        return self
    }
        
    @discardableResult
    func finally(_ closure: @escaping () -> Void) -> Self {
        return then { value in
            closure()
        }
    }
}
