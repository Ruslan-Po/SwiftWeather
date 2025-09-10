

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene  = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)
        
        let savedLat = UserDefaults.standard.double(forKey: "lastLatitude")
        let savedLon = UserDefaults.standard.double(forKey: "lastLongitude")
           
           if savedLat != 0.0 && savedLon != 0.0 {
               let mainScreenVC = MainScreenViewController()
               mainScreenVC.latitude = savedLat
               mainScreenVC.longitude = savedLon
               
               let rootNC = UINavigationController(rootViewController: mainScreenVC)
               window?.rootViewController = rootNC
               
           } else {
               let firstScreenVC = FirstScreenViewController()
               let rootNC = UINavigationController(rootViewController: firstScreenVC)
               window?.rootViewController = rootNC
           }
        self.window?.makeKeyAndVisible()
    }
}
