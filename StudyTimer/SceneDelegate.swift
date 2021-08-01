//
//  SceneDelegate.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var backgroundTaskID : UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)

    let cal = Calendar(identifier: .gregorian)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
        DataSaver.backgroundDate = Date()
        if UserDefaults.standard.bool(forKey: "edit") {
            UserDefaults.standard.setValue(true, forKey: "terminate")
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("active")
        
        guard DataSaver.backgroundDate != nil else { print("failed get data"); return }
        if let ela = cal.dateComponents([.second], from: DataSaver.backgroundDate, to: Date()).second {
            let ela_mod = UserDefaults.standard.bool(forKey: "play") ? ela : 0
            NotificationCenter.default.post(name: Notification.Name(rawValue: "ela"), object: nil, userInfo: ["state": ela_mod])
            print(ela_mod)
            UserDefaults.standard.setValue(ela_mod, forKey: "ela")
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        DataSaver.backgroundDate = Date()
        if UserDefaults.standard.bool(forKey: "edit") {
            UserDefaults.standard.setValue(true, forKey: "terminate")
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

