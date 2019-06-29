//
//  TrackManager.swift
//  BoseAR
//
//  Created by Austin Welch on 6/29/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import AVFoundation

var player: AVAudioPlayer?

class TrackManager {
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "Nature-sounds-birds", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return print("FAILURE") }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
