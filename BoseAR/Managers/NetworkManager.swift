//
//  NetworkManager.swift
//  BoseAR
//
//  Created by Austin Welch on 6/29/19.
//  Copyright © 2019 Austin Welch. All rights reserved.
//

import Alamofire

struct NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURLString = "https://hackathon.umusic.com"
    private let apiKey = "5dsb3jqxzX8D5dIlJzWoTaTM2TzcKufq1geS1SSb"
    
    public func requestTracks(_ completion: @escaping ([Track], Error?) -> Void) {
        
        let url = URL(string: "\(baseURLString)/prod/v1/tracks/")!
        
        let headers: HTTPHeaders = ["x-api-key": "q1WOBiu7kK6vlw3K7lDev6VRYKMZpVW72vAeWywP"]
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                completion([], error)
            } else if let data = response.data {
                guard let trackResponse = try? JSONDecoder().decode(TrackResponse.self, from: data) else {
                    return completion([], NSError(domain: "Error", code: 303, userInfo: nil))
                }
                completion(trackResponse.tracks, nil)
            }
        }
    }
}
