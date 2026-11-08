//
//  CYLSongInfo.swift
//  Example-SwiftUI
//
//  Created by 王双伟 on 2025/11/12.
//

import Foundation

struct CYLSongInfo: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    let album: String
    let duration: String

    init(id: UUID = UUID(), title: String, artist: String, album: String, duration: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
    }
}
