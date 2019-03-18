//
//  KaraokeSongsInteractor.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

protocol KaraokeSongsBusinessLogic
{
    func doFetchSongs(request: KaraokeSongs.KaraokeModels.Request)
    func doFetchNextSongs(request: KaraokeSongs.KaraokeModels.Request)
}

protocol KaraokeSongsDataStore
{
    //  var pageNumber: Int { get set }
}

class KaraokeSongsInteractor: KaraokeSongsBusinessLogic, KaraokeSongsDataStore
{
    var presenter: KaraokeSongsPresentationLogic?
    var worker: KaraokeSongsWorker?
    //  var pageNumber: Int = 1
    
    // MARK: Do FetchSongs
    func doFetchSongs(request: KaraokeSongs.KaraokeModels.Request)
    {
        //    var req = request
        //    req.page = pageNumber
        worker = KaraokeSongsWorker()
        worker?.doSongsFetchWork(request: request, completionHandler: { (result) in
            switch result {
            case .success(let songsResult):
                //            self.pageNumber += 1
                self.presenter?.presentKaraokeSongs(response: songsResult!)
            case .failure(let error):
                self.presenter?.presentError(error: error)
            }
        })
    }
    
    func doFetchNextSongs(request: KaraokeSongs.KaraokeModels.Request)
    {
        worker = KaraokeSongsWorker()
        worker?.doSongsFetchWorkForNext(request: request, completionHandler: { (result) in
            switch result {
            case .success(let songsResult):
                //            self.pageNumber += 1
                self.presenter?.presentKaraokeSongs(response: songsResult!)
            case .failure(let error):
                self.presenter?.presentError(error: error)
            }
        })
    }
}
