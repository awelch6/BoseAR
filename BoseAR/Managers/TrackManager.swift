//
//  TrackManager.swift
//  BoseAR
//
//  Created by Austin Welch on 6/29/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import AVFoundation

var player: AVQueuePlayer?


protocol TrackManagerDelegate: class {
    func player(_ player: AVPlayer, didFinishPlaying: Bool)
}

class TrackManager {

    weak var delegate: TrackManagerDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    public func stop() {
         player?.removeAllItems()
    }
    
    public func enqueue(track: Track) {
        guard let playerItem = playerItem(track: track) else {
            return
        }
        
        guard let p = player else {
            player = AVQueuePlayer(playerItem: playerItem)
            player?.play()
            return
        }
        
        p.insert(playerItem, after: p.items().last)
        p.play()
    }
    
    private func playerItem(track: Track) -> AVPlayerItem? {
        let urlString = "https://hackathon.umusic.com/prod/v1/isrc/\(track.isrc)/stream.m3u8"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let keyHeader = ["x-api-key": "5dsb3jqxzX8D5dIlJzWoTaTM2TzcKufq1geS1SSb"]
        
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": keyHeader])
        
        return AVPlayerItem(asset: asset)
    }
    
    @objc public func playerDidFinishPlaying() {
        guard let player = player else { return }
        
        delegate?.player(player, didFinishPlaying: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
