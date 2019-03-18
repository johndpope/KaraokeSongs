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
            let karaokeSong = getSongVM(model: song)
            songs.append(karaokeSong)
        }
        viewModel.karaokeSongs = songs
        viewController?.displayKaraokeSongs(viewModel: viewModel)
    }
    
    func getSongVM(model: KaraokeSongs.KaraokeModels.Track) -> KaraokeSongs.KaraokeModels.KaraokeSong {
        var karaokeSong = KaraokeSongs.KaraokeModels.KaraokeSong()
        karaokeSong.title = model.title
        karaokeSong.altTitle = model.altTitle
        karaokeSong.langCode = model.langCode
        karaokeSong.runtime = "\(String(describing: model.runtime))"
        karaokeSong.releaseDate = model.releaseDate//?.getDate()
        karaokeSong.lyricsCount = "Lyrics Count: \(model.lyricsCount ?? 0)"
        karaokeSong.originalLyricURL = model.originalLyricURL
        karaokeSong.imageUrl = URL(string: model.images?.poster.url ?? "")
        let genres = model.genres?.joined(separator:", ")
        karaokeSong.genres = "Genres: \(genres ?? "")"
        karaokeSong.artistCount = "Total Artists: \(model.trackArtists?.count ?? 0)"
        return karaokeSong
    }
    
    func presentError(error: APIError){
        let errorModel = KaraokeSongs.KaraokeModels.ErrorModel(message: error.localizedDescription)
        viewController?.displayError(errorModel: errorModel)
    }
}
