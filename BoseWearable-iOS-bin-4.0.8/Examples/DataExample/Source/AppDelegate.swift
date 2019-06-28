//
//  AppDelegate.swift
//  DataExample
//
//  Created by Paul Calnan on 8/13/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BLECore
import BoseWearable
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BoseWearable.configure()
        return true
    }
}
