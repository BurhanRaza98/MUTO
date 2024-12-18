//
//  ContentView.swift
//  MUTO
//
//  Created by Burhan Raza on 11/12/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TaskView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }

            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }

            SoundMixerView()
                .tabItem {
                    Image(systemName: "speaker.wave.2")
                    Text("Sound Mixer")
                }
        }
        .accentColor(Color.appForeground)
        .background(Color.appBackground)
    }
}


#Preview {
    ContentView()
}
