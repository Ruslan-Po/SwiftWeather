//
//  SceneDelegate.swift
//  weather_practice
//
//  Created by Ruslan Popovich on 28/08/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene  = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        self.window?.rootViewController = UINavigationController(rootViewController: MainScreenViewController())
        self.window?.makeKeyAndVisible()
        
    }

    

}

