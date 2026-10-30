//
//  Track.swift
//  Assignment8
//

import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
    var resourceName: String { (fileName as NSString).deletingPathExtension }
    var resourceExtension: String { (fileName as NSString).pathExtension }
}

enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Morning Song", artist: "Antti Luode", fileName: "morning_song.mp3", coverImageName: "cover_morning_song"),
        Track(title: "Mini Song", artist: "Antti Luode", fileName: "mini_song.mp3", coverImageName: "cover_mini_song"),
        Track(title: "Next Song", artist: "Antti Luode", fileName: "next_song.mp3", coverImageName: "cover_next_song"),
        Track(title: "Simple Song", artist: "Antti Luode", fileName: "simple_song.mp3", coverImageName: "cover_simple_song"),
        Track(title: "Tinkly Song", artist: "Antti Luode", fileName: "tinkly_song.mp3", coverImageName: "cover_tinkly_song"),
        Track(title: "Song for Morpheus", artist: "Antti Luode", fileName: "song_for_morpheus.mp3", coverImageName: "cover_song_for_morpheus"),
        Track(title: "Africa (Instrumental)", artist: "Antti Luode", fileName: "africa_instrumental.mp3", coverImageName: "cover_africa_instrumental"),
        Track(title: "Disco Zombies (Instrumental)", artist: "Antti Luode", fileName: "disco_zombies_instrumental.mp3", coverImageName: "cover_disco_zombies_instrumental"),
        Track(title: "Funk America (Instrumental)", artist: "Antti Luode", fileName: "funk_america_instrumental.mp3", coverImageName: "cover_funk_america_instrumental"),
        Track(title: "Fly Away (Instrumental)", artist: "Antti Luode", fileName: "fly_away_instrumental.mp3", coverImageName: "cover_fly_away_instrumental"),
    ]
}
