//
//  SceneDelegate.swift
//  SheeeeeeeeetDemo
//
//  Created by Daniel Saidi on 2019-08-19.
//  Copyright © 2019 Daniel Saidi. All rights reserved.
//

import UIKit
import Sheeeeeeeeet

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        ActionSheet.applyAppearance(.demo)
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}