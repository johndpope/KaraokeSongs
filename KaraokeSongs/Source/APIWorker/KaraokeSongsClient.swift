//
//  KaroakeSongsClient.swift
//  KaroakeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright © 2019 Nikhil Gohil. All rights reserved.
//

import Foundation

class KaraokeSongsClient: KaraokeSongsAPIClient {
    // MARK: - Singleton Pattern
    static let sharedInstance = KaraokeSongsClient(configuration: .background(withIdentifier: "KaroakeSongs"))
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
}

