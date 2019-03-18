//
//  KaraokeSongsPresenter.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

protocol KaraokeSongsPresentationLogic
{
  func presentKaraokeSongs(response: KaraokeSongs.KaraokeModels.Response)
  func presentError(error: APIError)
}

class KaraokeSongsPresenter: KaraokeSongsPresentationLogic
{
  weak var viewController: KaraokeSongsDisplayLogic?
  
  // MARK: Do Presentation logic
    
  func presentKaraokeSongs(response: KaraokeSongs.KaraokeModels.Response) {
    var viewModel = KaraokeSongs.KaraokeModels.ViewModel()
    if response.meta.next != nil && response.meta.next?.count ?? 0 > 0 {
        viewModel.nextCall = response.meta.next
    }
    var songs = [KaraokeSongs.KaraokeModels.KaraokeSong]()
    for song in response.tracks {
        let karaokeSong = KaraokeSongs.KaraokeModels.KaraokeSong(trackName: song.title)
        songs.append(karaokeSong)
    }
    viewModel.karaokeSongs = songs
    viewController?.displayKaraokeSongs(viewModel: viewModel)
  }
    
  func presentError(error: APIError){
    let erroeModel = KaraokeSongs.KaraokeModels.ErrorModel()
    viewController?.displayError(errorModel: erroeModel)
  }
}
