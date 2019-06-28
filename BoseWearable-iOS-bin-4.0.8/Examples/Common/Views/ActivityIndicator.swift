//
//  ActivityIndicator.swift
//  Common
//
//  Created by Paul Calnan on 11/19/18.
//  Copyright © 2018 Bose Corporation. All rights reserved.
//

import UIKit

class ActivityIndicator: UIView {
    private init(parentView: UIView) {
        super.init(frame: parentView.bounds)

        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor.clear

        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        let margin = CGFloat(30)

        let overlay = UIView(frame: CGRect(x: 0, y: 0,
                                           width: spinner.bounds.width + margin * 2,
                                           height: spinner.bounds.height + margin * 2))
        overlay.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.75)
        overlay.layer.cornerRadius = 10

        overlay.addSubview(spinner)
        spinner.center = overlay.center

        overlay.center = self.center
        addSubview(overlay)

        parentView.addSubview(self)
        spinner.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    static func add(to view: UIView?) -> ActivityIndicator? {
        guard let view = view else {
            return nil
        }
        return ActivityIndicator(parentView: view)
    }
}
