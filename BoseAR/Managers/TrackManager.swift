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
    
    public func enqueue(_ isrc: String) {
        guard let playerItem = playerItem(for: isrc) else {
            return
        }
        
        guard let p = player else {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error {
                print(error.localizedDescription)
            }
            player = AVQueuePlayer(playerItem: playerItem)
            player?.play()
            return
        }
        
        p.insert(playerItem, after: nil)
        p.play()
    }
    
    private func playerItem(for isrc: String) -> AVPlayerItem? {
        let urlString = "https://hackathon.umusic.com/prod/v1/isrc/\(isrc)/stream.m3u8"
        
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
