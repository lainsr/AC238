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

// This is the UIView that contains the AVPlayerLayer for rendering the video
class VideoPlayerUIView: UIView {
    private let player: AVPlayer
    private let playerLayer = AVPlayerLayer()
    private let videoPos: Binding<Double>
    private let videoDuration: Binding<Double>
    private let seeking: Binding<Bool>
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
  
    init(player: AVPlayer, videoPos: Binding<Double>, videoDuration: Binding<Double>, seeking: Binding<Bool>) {
        self.player = player
        self.videoDuration = videoDuration
        self.videoPos = videoPos
        self.seeking = seeking
        
        super.init(frame: .zero)
    
        backgroundColor = .lightGray
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.white.cgColor
        layer.addSublayer(playerLayer)
        
        // Observe the duration of the player's item so we can display it
        // and use it for updating the seek bar's position
        durationObservation = player.currentItem?.observe(\.duration, changeHandler: { [weak self] item, change in
            guard let self = self else { return }
            self.videoDuration.wrappedValue = item.duration.seconds
        })
        
        // Observe the player's time periodically so we can update the seek bar's
        // position as we progress through playback
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 1000), queue: nil) { [weak self] time in
            guard let self = self else { return }
            // If we're not seeking currently (don't want to override the slider
            // position if the user is interacting)
            guard !self.seeking.wrappedValue else {
                return
            }
        
            // update videoPos with the new video time (as a percentage)
            self.videoPos.wrappedValue = time.seconds / self.videoDuration.wrappedValue
        }
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
    
        playerLayer.frame = bounds
    }
    
    func cleanUp() {
        // Remove observers we setup in init
        durationObservation?.invalidate()
        durationObservation = nil
        
        if let observation = timeObservation {
            player.removeTimeObserver(observation)
            timeObservation = nil
        }
    }
  
}

// This is the SwiftUI view which wraps the UIKit-based PlayerUIView above
struct VideoPlayerView: UIViewRepresentable {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes, but we don't in this example
    }
    
    func makeUIView(context: UIViewRepresentableContext<VideoPlayerView>) -> UIView {
        let uiView = VideoPlayerUIView(player: player,
                                       videoPos: $videoPos,
                                       videoDuration: $videoDuration,
                                       seeking: $seeking)
        return uiView
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        guard let playerUIView = uiView as? VideoPlayerUIView else {
            return
        }
        playerUIView.cleanUp()
    }
}

// This is the SwiftUI view that contains the controls for the player
struct VideoPlayerControlsView : View {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    @State private var playerPaused = true
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: previous10Seconds) {
                    Image(systemName: "gobackward.10")
                        .font(.largeTitle)
                }
                .padding(EdgeInsets(top: 0, leading: 30, bottom: 10, trailing: 10))
                Spacer()
                Button(action: next10Seconds) {
                    Image(systemName: "goforward.10")
                        .font(.largeTitle)
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 30))
            }
            HStack {
                // Play/pause button
                Button(action: togglePlayPause) {
                    Image(systemName: playerPaused ? "play" : "pause")
                        .font(.title3)
                        .frame(width: 24, height: 24, alignment: .leading)
                }
                .fixedSize(horizontal: true, vertical: false)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0))
                // Current video time
                Text("\(Utility.formatSecondsToHMS(videoPos * videoDuration))")
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 60, height: 24, alignment: .leading)
                // Slider for seeking / showing video progress
                GeometryReader { sliderGeo in
                    Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: CoordinateSpace.local)
                            .onEnded({ value in
                                let percent = min(max(0, Double(value.location.x / sliderGeo.size.width * 1)), 1)
                                self.videoPos = percent
                                goto(percent: percent)
                        }))
                }.frame(width: nil, height: 32, alignment: .center)
                // Video duration
                Text("\(Utility.formatSecondsToHMS(videoDuration))")
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .background(Color.white)
            .cornerRadius(13)
            .shadow(radius: 5.0)
        }
    }
    
    private func goto(percent: Double) {
        var nextSeconds : Double
        if percent > 0.0 {
            nextSeconds = videoDuration / percent
        } else {
            nextSeconds = 0;
        }
        let nextTime = CMTime(seconds: nextSeconds, preferredTimescale: 1000)
        player.seek(to: nextTime)
    }
    
    private func next10Seconds() {
        seek(seconds: 10.0)
    }
    
    private func previous10Seconds() {
        seek(seconds: -10.0)
    }
    
    private func seek(seconds: Double) {
        let currentTime = player.currentTime()
        var nextSeconds = currentTime.seconds + seconds
        if nextSeconds < 0 {
            nextSeconds = 0
        }
        let nextTime = CMTime(seconds: nextSeconds, preferredTimescale: 1000)
        player.seek(to: nextTime)
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

// This is the SwiftUI view which contains the player and its controls
struct VideoPlayerContainerView : View {
    // The progress through the video, as a percentage (from 0 to 1)
    @State private var videoPos: Double = 0
    // The duration of the video in seconds
    @State private var videoDuration: Double = 0
    // Whether we're currently interacting with the seek bar or doing a seek
    @State private var seeking = false
    
    @State private var showControls = true
    
    private let player: AVPlayer
  
    init(file: ACFile, path: String) {
        let path = path + "/" + file.name
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
    }
  
    var body: some View {
        ZStack {
            VideoPlayerView(videoPos: $videoPos,
                            videoDuration: $videoDuration,
                            seeking: $seeking,
                            player: player)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                VideoPlayerControlsView(videoPos: $videoPos,
                                        videoDuration: $videoDuration,
                                        seeking: $seeking,
                                        player: player)
                .padding()
            }
            .opacity(showControls ? 1.0 : 0.0)
            .animation(.easeInOut)
            
        }
        .onTapGesture {
            self.showControls.toggle()
        }
        .onDisappear {
            // When this View isn't being shown anymore stop the player
            self.player.replaceCurrentItem(with: nil)
        }
    
    }
}

// This is the main SwiftUI view for this app, containing a single PlayerContainerView
struct VideoView: View {
    
    let file: ACFile
    let path: String
    
    var body: some View {
        VideoPlayerContainerView(file: file, path: path)
    }
}


