//
//  KaroakeSongsEndPoint.swift
//  KaroakeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright © 2019 Nikhil Gohil. All rights reserved.
//

import Foundation

struct API {
    static let apiVersion = "/v3/"
    static let songs = "songs.json"
    static let GET = "GET"
}

protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var queryParams: [URLQueryItem] { get set }
}

extension Endpoint {
    
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        if !queryParams.isEmpty {
            components.queryItems = queryParams
        }
        return components
    }
    
    var urlRequest: URLRequest {
        let url = urlComponents.url!
        var request = URLRequest(url: url)
        let headers = request.allHTTPHeaderFields ?? [:]
        request.allHTTPHeaderFields = headers
        return request
    }
    
    var hosname: String {
        return base
    }
    
}

enum KaraokeSongsCalls {
    case songsBy
}

extension KaraokeSongsCalls: Endpoint {
    
    struct Query {
        static var params:[URLQueryItem] = [URLQueryItem]()
    }
    
    var queryParams: [URLQueryItem] {
        get {
            return Query.params
        }
        set (newValue) {
            Query.params = newValue
        }
    }
    
    var base: String {
        enum Environment: String {
            case Production = "poduction_host"
            case Debug = "debug_host"
            case Staging = "https://api-staging.popsical.tv"
        }
        let env = Environment.Staging.rawValue
        return env
    }
    
    var path: String {
        switch self {
        case .songsBy:
            return API.apiVersion+API.songs
        }
    }
}

