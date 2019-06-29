//
//  SoundZone.swift
//  BoseAR
//
//  Created by Andrew O'Brien on 6/29/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import MapKit

class SoundZone: CLCircularRegion {
    
    let soundURL: String
    
    init(soundURL: String, center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        self.soundURL = soundURL
        super.init(center: center, radius: radius, identifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
