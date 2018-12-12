//
//  Post.swift
//  Post
//
//  Created by Greg Hughes on 12/10/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import Foundation

struct Post: Codable {
    let text : String
    let timestamp : TimeInterval
    let username : String
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
    
    var queryTimestamp : TimeInterval {
        
        return self.timestamp - 0.00001
        
    }
    
    
}
