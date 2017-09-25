//
//  WSNetworkIndicator.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 12/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Foundation

/**
    Abstracts network activity indicator management.
    - This only shows activity indicator for requests longer than 1 second, the loader is not shown for quick requests.
    - This also waits for 0.2 seconds before hiding the indicator in case other simultaneous requests
    occur in order to avoid flickering.
 
 */
class WSNetworkIndicator: NSObject {
    
    static let shared = WSNetworkIndicator()
    private var runningRequests = 0

    func startRequest() {
        runningRequests += 1
        // For some unowned reason using scheduledTimer does not work in this case.
        let timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    func stopRequest() {
        runningRequests -= 1
        // For some unowned reason using scheduledTimer does not work in this case.
        let timer = Timer(timeInterval: 0.2, target: self, selector: #selector(tick), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    
    @objc
    func tick() {
        let previousValue = UIApplication.shared.isNetworkActivityIndicatorVisible
        let newValue = (runningRequests != 0)
        if newValue != previousValue {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
}
