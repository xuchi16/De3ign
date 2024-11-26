//
//  ModelContainerViewModel.swift
//  Tv_test
//
//  Created by Jovita on 2024/11/13.
//

import SwiftUI
import AVKit
import RealityKit

struct VideoPlayerView: View {
    @State private var player = AVPlayer()
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var videoDuration: Double? = nil
    
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            VideoPlayer(player: player)
                .frame(width: 640, height: 360)
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
                .onDisappear {
                    player.pause()
                    player.replaceCurrentItem(with: nil)
                }
            
            HStack(spacing: 20) {
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                if let duration = videoDuration {
                    Slider(value: $currentTime, in: 0...duration) { editing in
                        if !editing {
                            player.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1000))
                        }
                    }
                    .accentColor(.white)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            setupPlayer()
        }
        .onReceive(timer) { _ in
            if isPlaying, let currentItem = player.currentItem {
                self.currentTime = currentItem.currentTime().seconds
            }
        }
    }
    
    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("警告: 无法找到视频文件")
            return
        }
        
        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        
        player.automaticallyWaitsToMinimizeStalling = false
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main) { [self] _ in
                isPlaying = false
                currentTime = 0
                player.seek(to: .zero)
            }
        
        player.replaceCurrentItem(with: playerItem)
        
        Task {
            let duration = try? await playerItem.asset.load(.duration)
            videoDuration = duration?.seconds
        }
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
        }
        
        // 移除 loadValues 调用，直接播放
        DispatchQueue.main.async { [self] in
            player.play()
            isPlaying = true
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}

#Preview {
    VideoPlayerView()
}
