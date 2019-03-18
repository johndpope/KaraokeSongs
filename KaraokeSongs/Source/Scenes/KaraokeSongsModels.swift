//
//  KaraokeSongsModels.swift
//  KaraokeSongs
//
//  Created by Nikhil Gohil on 17/03/2019.
//  Copyright (c) 2019 Nikhil Gohil. All rights reserved.
//

import UIKit

enum KaraokeSongs
{
    // MARK: Use cases
    
    enum KaraokeModels
    {
        struct Request
        {
            let per_page = 25
            let page : Int = 1
            var nextCall : String?
        }
        
        struct Response : Codable {
            let tracks: [Track]
            let meta: Meta
        }
        
        
        struct Meta: Codable {
            let total, currentPage, numPages, perPage: Int?
            let previous: String?
            let next: String?
            
            enum CodingKeys: String, CodingKey {
                case total
                case currentPage = "current_page"
                case numPages = "num_pages"
                case perPage = "per_page"
                case previous, next
            }
        }
        
        struct Track: Codable {
            let id: Int
            let number: JSONNull?
            let title, altTitle: String?
            let langCode: String?
            let runtime: Int?
            let releaseDate: String?
            let hasVideo: Bool?
            let genres: [String]?
            let source: String?
            let images: Images?
            let lyricsCount: Int?
            let block: Bool?
            let originalLyricURL: String?
            let hasLrc: Bool?
            let musicFeatureKey, musicFeatureIsMajor: Int?
            let blockReason: BlockReason?
            let trackArtists: [TrackArtist]?
            
            enum CodingKeys: String, CodingKey {
                case id, number, title
                case altTitle = "alt_title"
                case langCode = "lang_code"
                case runtime
                case releaseDate = "release_date"
                case hasVideo = "has_video"
                case genres, source, images
                case lyricsCount = "lyrics_count"
                case block
                case originalLyricURL = "original_lyric_url"
                case hasLrc = "has_lrc"
                case musicFeatureKey = "music_feature_key"
                case musicFeatureIsMajor = "music_feature_is_major"
                case blockReason = "block_reason"
                case trackArtists = "track_artists"
            }
        }
        
        struct BlockReason: Codable {
            let countryBlocked, platformBlocked, timeLapsedBlocked: Bool
            
            enum CodingKeys: String, CodingKey {
                case countryBlocked = "country_blocked"
                case platformBlocked = "platform_blocked"
                case timeLapsedBlocked = "time_lapsed_blocked"
            }
        }
        
        struct Images: Codable {
            let poster: Poster
        }
        
        struct Poster: Codable {
            let url: String
        }
        
        struct TrackArtist: Codable {
            let type: String?
            let artist: Artist?
        }
        
        struct Artist: Codable {
            let id: Int?
            let name, altName: String?
            let gender: String?
            let langCodes: [String]?
            let images: Images?
            let totalTracks: Int?
            
            enum CodingKeys: String, CodingKey {
                case id, name
                case altName = "alt_name"
                case gender
                case langCodes = "lang_codes"
                case images
                case totalTracks = "total_tracks"
            }
        }
        
        
        // MARK: Encode/decode helpers
        
        class JSONNull: Codable, Hashable {
            
            public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
                return true
            }
            
            public var hashValue: Int {
                return 0
            }
            
            public init() {}
            
            public required init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }
        
        
        struct ViewModel
        {
            var karaokeSongs : [KaraokeSong]?
            var nextCall: String?
        }
        
        struct KaraokeSong {
            var title,altTitle, langCode, runtime, hasVideo, lyricsCount,originalLyricURL, genres, artistCount,releaseDate : String?
            var imageUrl : URL?
            var artistImages : [URL]?
        }
        
        struct ErrorModel
        {
            let title = "Error"
            let message : String
        }
    }
}
