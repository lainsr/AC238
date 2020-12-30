//
//  SceneDelegate.swift
//  AC238
//
//  Created by Stéphane Rossé on 11.03.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let rootDirectory = (UIApplication.shared.delegate as! AppDelegate).applicationDocumentsDirectory()
        let rootContent = SceneDelegate.listFiles(filesOf: rootDirectory)
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let davObserver = (UIApplication.shared.delegate as! AppDelegate).davObserver()

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let contentView = RootContentList(contentName: "AC238", directoryPath: rootDirectory, contentArray: rootContent, davObserver: davObserver)
            .environment(\.managedObjectContext, context)
        
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    static func listFiles(filesOf directory: String) -> [ACFile] {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: directory)
            var acFiles = [ACFile]()
            var counter = 0
            for fileName in files {
                if fileName.hasPrefix(".") {
                    continue
                }
                let acFile = file(id: counter, fileName: fileName, directory: directory)
                acFiles.append(acFile)
                counter += 1
            }
            acFiles.sort() {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
            return acFiles;
        } catch {
            print("Error: \(error.localizedDescription)")
            return [ACFile]()
        }
    }
    
    static func counter() -> Int {
        struct Holder {
            static var timesCalled = 0
        }
        Holder.timesCalled += 1
        return Holder.timesCalled
    }
    
    static func file(id: Int, fileName: String, directory: String) -> ACFile {
        var symboleName: String = ""
        var thumbnailName: String = ""
        var isDirectory = false

        if ACFile.hasImageSuffix(filename: fileName) {
            thumbnailName = fileName
        } else if ACFile.hasVideoSuffix(filename: fileName) {
            symboleName = "video"
        } else if(directoryExistsAtPath(directory, file: fileName)) {
            symboleName = "folder"
            isDirectory = true
        } else {
            symboleName = "doc"
        }
        
        return ACFile(id: id, name: fileName, path: directory, directory: isDirectory, symbol:symboleName, thumbnailName: thumbnailName)
    }
    
    static func directoryExistsAtPath(_ path: String, file filename: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

