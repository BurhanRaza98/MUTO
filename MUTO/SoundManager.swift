 
import AVFoundation
import SwiftUI
import AVKit

class SoundManager {
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    // Make initializer public
    public init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(named name: String, volume: Float) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Could not find sound file: \(name)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Loop indefinitely
            player.volume = volume
            player.prepareToPlay()
            player.play()
            audioPlayers[name] = player
            print("Successfully started playing: \(name)")
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func stopSound(named name: String) {
        if let player = audioPlayers[name] {
            player.stop()
            audioPlayers.removeValue(forKey: name)
            print("Stopped playing: \(name)")
        }
    }
    
    func updateVolume(named name: String, volume: Float) {
        if let player = audioPlayers[name] {
            player.volume = volume
            print("Updated volume for \(name) to \(volume)")
        }
    }
    
    func stopAllSounds() {
        for (name, player) in audioPlayers {
            player.stop()
            print("Stopped playing: \(name)")
        }
        audioPlayers.removeAll()
    }
}
