//
//  WSNetworkIndicator.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 12/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation
import UIKit

/**
    Abstracts network activity indicator management.
    - This only shows activity indicator for requests longer than 1 second, the loader is not shown for quick requests.
    - This also waits for 0.2 seconds before hiding the indicator in case other simultaneous requests
    occur in order to avoid flickering.
 
 */
class WSNetworkIndicator {

    static let shared = WSNetworkIndicator()
    private var runningRequests = 0

    func startRequest() {
        runningRequests += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.tick()
        }
    }

    func stopRequest() {
        runningRequests -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) { [weak self] in
            self?.tick()
        }
    }

    func tick() {
        let previousValue = UIApplication.shared.isNetworkActivityIndicatorVisible
        let newValue = (runningRequests > 0)
        if newValue != previousValue {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
}
