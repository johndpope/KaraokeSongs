//
//  KaraokeSongsWorker.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

class KaraokeSongsWorker : KaraokeSongsClient
{
    func doSongsFetchWork(request: KaraokeSongs.KaraokeModels.Request, completionHandler:  @escaping (APIResult<KaraokeSongs.KaraokeModels.Response?, APIError>) -> Void) {
        var endpoint = KaraokeSongsCalls.songsBy
        endpoint.queryParams = self.getQueryParams(request: request)
        var urlRequest = endpoint.urlRequest
        // we can set http method and headers here.
        urlRequest.httpMethod = API.GET
        fetch(with: urlRequest, decode: { json -> KaraokeSongs.KaraokeModels.Response? in
            guard let songsResult = json as? KaraokeSongs.KaraokeModels.Response else { return  nil }
            return songsResult
        }, completion:completionHandler)
    }
    
    func doSongsFetchWorkForNext(request: KaraokeSongs.KaraokeModels.Request, completionHandler:  @escaping (APIResult<KaraokeSongs.KaraokeModels.Response?, APIError>) -> Void) {
        let urlRequest = URLRequest(url: URL(string: request.nextCall!)!)
        // we can set http method and headers here.
        fetch(with: urlRequest, decode: { json -> KaraokeSongs.KaraokeModels.Response? in
            guard let songsResult = json as? KaraokeSongs.KaraokeModels.Response else { return  nil }
            return songsResult
        }, completion:completionHandler)
    }

    func getQueryParams(request: KaraokeSongs.KaraokeModels.Request) -> [URLQueryItem]{
        return [URLQueryItem(name: "per_page", value: "\(request.per_page)"),URLQueryItem(name: "page", value: "\(request.page)")]
    }
}
