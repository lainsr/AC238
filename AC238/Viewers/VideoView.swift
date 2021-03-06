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
    
    private let fontColor = Color(red: 225 / 255, green: 225 / 255, blue: 225 / 255)
    private let backgroundColor = Color(red: 75 / 255, green: 75 / 255, blue: 75 / 255)
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    // Whether the video controls are showned or not
    @Binding private(set) var showControls : Bool
    // List of the tasks to hide the controls after 5 seconds
    @Binding private(set) var queuedHideTask : [DispatchWorkItem]
    
    let player: AVPlayer
    
    @State private var playerPaused = true
    
    var body: some View {
        VStack {
            HStack {
                Button(action: previous10Seconds) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                }
                Button(action: previous30Seconds) {
                    Image(systemName: "gobackward.30")
                        .font(.title)
                }
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0))
                Spacer()
                // Play/pause button
                Button(action: togglePlayPause) {
                    Image(systemName: playerPaused ? "play" : "pause")
                        .font(.largeTitle)
                }
                Spacer()
                Button(action: next30Seconds) {
                    Image(systemName: "goforward.30")
                        .font(.title)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))
                Button(action: next10Seconds) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                }
            }
            .padding(EdgeInsets(top: 7, leading: 7, bottom: 0, trailing: 7))
            HStack {
                // Current video time
                Text("\(Utility.formatSecondsToHMS(videoPos * videoDuration))")
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 60, height: 24, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0))
                // Slider for seeking / showing video progress
                GeometryReader { sliderGeo in
                    Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: CoordinateSpace.local)
                            .onEnded({ value in
                                let percent = min(max(0, Double(value.location.x / sliderGeo.size.width * 1)), 1)
                                self.videoPos = percent
                                goto(percent: percent)
                        }))
                        .accentColor(fontColor)
                }.frame(width: nil, height: 32, alignment: .center)
                // Video duration
                Text("\(Utility.formatSecondsToHMS(videoDuration))")
                    .frame(width: 60, height: 24, alignment: .trailing)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))
            }
        }
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(backgroundColor)
        .foregroundColor(fontColor)
        .opacity(0.8)
        .cornerRadius(13)
    }
    
    private func goto(percent: Double) {
        var nextSeconds : Double
        if percent > 0.0 {
            nextSeconds = videoDuration * percent
        } else {
            nextSeconds = 0;
        }
        let nextTime = CMTime(seconds: nextSeconds, preferredTimescale: 1000)
        player.seek(to: nextTime)
    }
    
    private func next10Seconds() {
        seek(seconds: 10.0)
    }
    
    private func next30Seconds() {
        seek(seconds: 30.0)
    }
    
    private func previous10Seconds() {
        seek(seconds: -10.0)
    }
    
    private func previous30Seconds() {
        seek(seconds: -30.0)
    }
    
    private func seek(seconds: Double) {
        let currentTime = player.currentTime()
        var nextSeconds = currentTime.seconds + seconds
        if nextSeconds < 0 {
            nextSeconds = 0
        }
        let nextTime = CMTime(seconds: nextSeconds, preferredTimescale: 1000)
        player.seek(to: nextTime)
        cancelHideTasks()
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
        cancelHideTasks()
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
        
        cancelHideTasks()
    }
    
    private func cancelHideTasks() {
        for hideTask in queuedHideTask {
            hideTask.cancel()
        }
        self.queuedHideTask.removeAll()
        
        let task = DispatchWorkItem {
            self.showControls = false
        }
        self.queuedHideTask.append(task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
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
    // Whether the video controls are showned or not
    @State private var showControls = true
    // List of the tasks to hide the controls after 5 seconds
    @State private var queuedHideTask = [DispatchWorkItem]()
    
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
                                        showControls: $showControls,
                                        queuedHideTask: $queuedHideTask,
                                        player: player)
                .padding()
            }
            .opacity(showControls ? 1.0 : 0.0)
            .animation(.easeInOut)
        }
        .onAppear {
            queueHideControls();
        }
        .onDisappear {
            // When this View isn't being shown anymore stop the player
            self.player.replaceCurrentItem(with: nil)
        }
        .onTapGesture {
            self.showControls.toggle()
            if(self.showControls) {
                queueHideControls();
            }
        }
    }
    
    private func queueHideControls() {
        for hideTask in queuedHideTask {
            hideTask.cancel()
        }
        self.queuedHideTask.removeAll()
        
        let task = DispatchWorkItem {
            self.showControls = false
        }
        self.queuedHideTask.append(task)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
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


