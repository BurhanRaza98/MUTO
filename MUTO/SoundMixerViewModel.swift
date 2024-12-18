//
//  SoundMixerViewModel.swift
//  MUTO
//
//  Created by Burhan Raza on 16/12/24.
//
import SwiftUI
import AVFoundation
import AVKit
class SoundMixerViewModel: ObservableObject {
    @Published var soundTracks: [SoundTrack] = [
        SoundTrack(name: "Ocean-Waves", volume: 0.5),
        SoundTrack(name: "Fireplace", volume: 0.5),
        SoundTrack(name: "Birds-Chirping", volume: 0.5)
    ]
    
    @Published var isPlayingAll: Bool = false
    private var audioPlayers: [UUID: AVAudioPlayer] = [:]
    
    init() {
        setupAudioSession()
        setupAudioPlayers()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupAudioPlayers() {
        for index in soundTracks.indices {
            if let url = Bundle.main.url(forResource: soundTracks[index].name, withExtension: "mp3") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.numberOfLoops = -1
                    player.prepareToPlay()
                    player.volume = Float(soundTracks[index].volume)
                    audioPlayers[soundTracks[index].id] = player
                } catch {
                    print("Failed to load \(soundTracks[index].name): \(error)")
                }
            }
        }
    }
    
    func togglePlayAll() {
        isPlayingAll.toggle()
        for index in soundTracks.indices {
            soundTracks[index].isPlaying = isPlayingAll
            if let player = audioPlayers[soundTracks[index].id] {
                if isPlayingAll {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
    }
    
    func togglePlay(for trackId: UUID) {
        if let index = soundTracks.firstIndex(where: { $0.id == trackId }) {
            soundTracks[index].isPlaying.toggle()
            if let player = audioPlayers[trackId] {
                if soundTracks[index].isPlaying {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
    }
    
    func updateVolume(for trackId: UUID, volume: Double) {
        if let player = audioPlayers[trackId] {
            player.volume = Float(volume)
        }
    }
}

struct SoundTrack: Identifiable {
    let id = UUID()
    let name: String
    var volume: Double
    var isPlaying: Bool = false
}


