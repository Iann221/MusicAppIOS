//
//  TrackModel.swift
//  MusicAppIOS
//
//  Created by Vincentius Ian Widi Nugroho on 22/02/25.
//

import Foundation

// MARK: - Track Model
struct TrackModel: Codable {
    let name: String
    let playcount: String
}

// MARK: - API Response Model
struct TopTracksResponse: Codable {
    let toptracks: TrackContainer
}

struct TrackContainer: Codable {
    let track: [TrackModel]
}
