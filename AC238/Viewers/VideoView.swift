//
//  PlayerVideoView.swift
//  AC238
//
//  Created by Stéphane Rossé on 25.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import SwiftUI
import AVKit
import AVFoundation



// This is the main SwiftUI view for this app, containing a single PlayerContainerView
struct VideoView: View {

    @State private var showControls = true
    @State private var duration : Double = 0.0
    
    private var durationObservation: NSKeyValueObservation?
    
    let file: ACFile
    let path: String
    let player: AVPlayer
    
    init(file: ACFile, path: String) {
        self.file = file
        self.path = path
        let fullPath = path + "/" + file.name
        player = AVPlayer(url: URL(fileURLWithPath: fullPath))
        
        durationObservation = player.currentItem?.observe(\.duration, changeHandler: { [self] item, change in
            self.duration = item.duration.seconds
            print("First Duration \(self.duration) and item \(item.duration.seconds)")
        })
    }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
            VStack {
                Spacer()
                Text("\(Utility.formatSecondsToHMS(duration))")
                Spacer()
                VideoPlayerControlsView(player: player)
                    .padding()
            }
            .opacity(showControls ? 1.0 : 0.0)
            .animation(.easeInOut)
        }
    }
}

// This is the SwiftUI view that contains the controls for the player
struct VideoPlayerControlsView : View {
    let player: AVPlayer
    
    @State private var videoPos = 0.0
    @State private var videoDuration = 0.0
    @State private var seeking = false
    
    @State private var playerPaused = true
    
    init(player: AVPlayer) {
        self.player = player
    }

    var body: some View {
        HStack {
            // Play/pause button
            Button(action: togglePlayPause) {
                Image(systemName: playerPaused ? "play" : "pause")
                    .padding(.trailing, 10)
            }
            // Current video time
            Text("\(Utility.formatSecondsToHMS(videoPos * videoDuration))")
            // Slider for seeking / showing video progress
            Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
            // Video duration
            Text("\(Utility.formatSecondsToHMS(videoDuration))")
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(Color.white)
        .cornerRadius(13)
        .shadow(radius: 5.0)
    }
    
    private func togglePlayPause() {
        pausePlayer(!playerPaused)
    }
    
    private func pausePlayer(_ pause: Bool) {
        playerPaused = pause
        if playerPaused {
            player.pause()
        } else {
            player.play()
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Set a flag stating that we're seeking so the slider doesn't
            // get updated by the periodic time observer on the player
            seeking = true
            pausePlayer(true)
        }
        
        // Do the seek if we're finished
        if !editingStarted {
            let targetTime = CMTime(seconds: videoPos * videoDuration,
                                    preferredTimescale: 600)
            player.seek(to: targetTime) { _ in
                // Now the seek is finished, resume normal operation
                self.seeking = false
                self.pausePlayer(false)
            }
        }
    }
}
