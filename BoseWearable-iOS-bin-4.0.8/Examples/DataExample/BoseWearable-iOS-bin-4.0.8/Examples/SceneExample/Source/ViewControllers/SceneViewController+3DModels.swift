//
//  SceneViewController+3DModels.swift
//  SceneExample
//
//  Created by Alexander Mason on 3/12/19.
//  Copyright © 2019 Bose Corporation. All rights reserved.
//

import Foundation
import SceneKit

/// Scene loading utilities
extension SceneViewController {

    /**
     Returns a SCNScene that contains a corresponding 3D model for a productID and variant. If the productID or variant are not expected values default values will be used.

     - parameter productID: The product ID of the Bose device.
     - parameter variant: The variant of the Bose device.
     */
    func scene(forProduct productID: UInt16, variant: UInt8) -> SCNScene? {
        switch BoseProduct(rawValue: productID) {
        case .some(.Frames):
            switch FramesVariant(rawValue: variant) {
            case .some(.rondo):
                return SCNScene(named: "rondo.scn", inDirectory: "Assets.scnassets", options: nil)

            case .some(.alto), .none:
                return SCNScene(named: "alto.scn", inDirectory: "Assets.scnassets", options: nil)

            }

        case .some(.QC35):
            return scene(for: QC35Variant(rawValue: variant) ?? .black)

        case .none:
            return SCNScene(named: "alto.scn", inDirectory: "Assets.scnassets", options: nil)

        }
    }

    /**
     Returns a SCNScene containing a QC35-II model with the appropriate materials. This function manually updates the model's materials with the
     appropriate textures because SceneKit doesn't support the idea of global materials that we can reference through code.
     */
    fileprivate func scene(for variant: QC35Variant) -> SCNScene? {
        let scene = SCNScene(named: "QC35.scn", inDirectory: "Assets.scnassets", options: nil)

        // Update the textures for the material of the earcup and therefore all other geometries that use the same material.
        guard let earCup = scene?.rootNode.childNode(withName: "QC35_Ear_Cup_R", recursively: true) else {
            fatalError("Right ear cup is not available.")
        }

        earCup.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT01_\(variant.color)_Diffuse.png",
            in: Bundle.main,
            compatibleWith: nil)
        earCup.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT01_\(variant.color)_Metallic.png",
            in: Bundle.main,
            compatibleWith: nil)
        earCup.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT01_\(variant.color)_Normal.png",
            in: Bundle.main,
            compatibleWith: nil)
        earCup.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT01_\(variant.color)_Roughness.png",
            in: Bundle.main,
            compatibleWith: nil)

        // Update the yoke material, which will update all other geometries on the model.
        guard let yoke = scene?.rootNode.childNode(withName: "QC35_Yoke_R", recursively: true) else {
            fatalError("Right yoke is not available.")
        }

        yoke.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT02_\(variant.color)_Diffuse.png",
            in: Bundle.main,
            compatibleWith: nil)
        yoke.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT02_\(variant.color)_Metallic.png",
            in: Bundle.main,
            compatibleWith: nil)
        yoke.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT02_\(variant.color)_Normal.png",
            in: Bundle.main,
            compatibleWith: nil)
        yoke.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(variant.textureRoot)/QC35_MAT02_\(variant.color)_Roughness.png",
            in: Bundle.main,
            compatibleWith: nil)

        return scene
    }

    fileprivate enum QC35Variant: UInt8 {
        case black = 1
        case silver = 2

        var textureRoot: String {
            switch self {
            case .black:
                return "Assets.scnassets/QC35-Black"

            case .silver:
                return "Assets.scnassets/QC35-Silver"

            }
        }

        // Determine whether to use black textures or silver textures.
        var color: String {
            switch self {
            case .black:
                return "Black"

            case .silver:
                return "Silver"

            }
        }
    }

    fileprivate enum FramesVariant: UInt8 {
        case alto = 1
        case rondo = 2
    }

    fileprivate enum BoseProduct: UInt16 {
        case Frames = 0x402C
        case QC35 = 0x4020
    }
}
