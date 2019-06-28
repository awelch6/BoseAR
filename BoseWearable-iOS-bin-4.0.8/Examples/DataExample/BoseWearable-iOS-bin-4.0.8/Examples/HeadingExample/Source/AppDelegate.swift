//
//  AppDelegate.swift
//  HeadingExample
//
//  Created by Paul Calnan on 2/16/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import BoseWearable
import Logging
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        BoseWearable.configure()
        // Log.location.isEnabled = true
        return true
    }
}
