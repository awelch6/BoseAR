//
//  AppDelegate.swift
//  SceneExample
//
//  Created by Paul Calnan on 7/16/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import BoseWearable
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BoseWearable.enableCommonLogging()
        BoseWearable.configure()

        application.isIdleTimerDisabled = true
        return true
    }
}
