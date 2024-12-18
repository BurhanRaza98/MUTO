//
//  SoundMixerView.swift
//  MUTO
//
//  Created by Burhan Raza on 11/12/24.
//

import SwiftUI
import AVKit
import AVFoundation

struct SoundMixerView: View {
    @StateObject private var viewModel = SoundMixerViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sound Mixer")
                    .font(.title)
                    .padding()
                
                ForEach(viewModel.soundTracks.indices, id: \.self) { index in
                    SoundTrackRow(
                        name: viewModel.soundTracks[index].name,
                        volume: Binding(
                            get: { viewModel.soundTracks[index].volume },
                            set: { viewModel.soundTracks[index].volume = $0 }
                        ),
                        isPlaying: Binding(
                            get: { viewModel.soundTracks[index].isPlaying },
                            set: { viewModel.soundTracks[index].isPlaying = $0 }
                        ),
                        viewModel: viewModel,
                        track: viewModel.soundTracks[index]
                    )
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.togglePlayAll()
                }) {
                    Text(viewModel.isPlayingAll ? "Pause All" : "Play All")
                        .foregroundColor(Color.appForeground)
                        .padding()
                        .background(Color.appAccent)
                        .cornerRadius(10)
                }
                .padding()
            }
            .background(Color.appBackground)
            .accentColor(Color.appForeground)
        }
    }
}

struct SoundTrackRow: View {
    let name: String
    @Binding var volume: Double
    @Binding var isPlaying: Bool
    let viewModel: SoundMixerViewModel
    let track: SoundTrack
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(Color.appForeground)
            
            Slider(value: $volume)
                .accentColor(Color.appAccent)
                .onChange(of: volume) { oldValue, newValue in
                    viewModel.updateVolume(for: track.id, volume: newValue)
                }
            
            Button(action: {
                viewModel.togglePlay(for: track.id)
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(Color.appForeground)
            }
        }
        .padding()
    }
}

