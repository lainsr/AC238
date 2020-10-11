//
//  AppDelegate.swift
//  AC238
//
//  Created by Stéphane Rossé on 11.03.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

//
// /Users/cyberia/Library/Developer/CoreSimulator/Devices/92FA7164-D737-499F-9C10-C90CA45B1650/data/Containers/Data/Application/18606E05-417F-4C9E-A708-F02B709BA66D/Library/Application\ Support/resources
//

import UIKit
import CoreData
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCDWebDAVServerDelegate {

    private var davServer : GCDWebDAVServer?
    private let webdavObserver = WebDAVObserver()
    
    override init() {
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let appSupportDirectory = applicationDocumentsDirectory()
        let filemgr = FileManager.default
        if(!filemgr.fileExists(atPath: appSupportDirectory)) {
            do {
                try filemgr.createDirectory(atPath: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        //print("Path \(appSupportDirectory)")
          
        davServer = GCDWebDAVServer(uploadDirectory: appSupportDirectory)
        davServer?.start(withPort: 8080, bonjourName: "AC238")
        davServer?.delegate = self

        return true
    }
    
    //- (void)davServer:(GCDWebDAVServer*)server didUploadFileAtPath:(NSString*)path;
    func davServer(_ server: GCDWebDAVServer, didUploadFileAtPath path: String) {
        DispatchQueue.main.async {
            self.webdavObserver.lastAdditions.append(path)
        }
    }
    
    //- (void)davServer:(GCDWebDAVServer*)server didCreateDirectoryAtPath:(NSString*)path;
    func davServer(_ server: GCDWebDAVServer, didCreateDirectoryAtPath path: String) {
        DispatchQueue.main.async {
            self.webdavObserver.lastAdditions.append(path)
        }
    }
    
    //- (void)davServer:(GCDWebDAVServer*)server didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath;
    func davServer(_ server: GCDWebDAVServer, didMoveItemFromPath fromPath: String, toPath: String) {
        DispatchQueue.main.async {
            self.webdavObserver.lastRemovals.append(fromPath)
            self.webdavObserver.lastAdditions.append(toPath)
        }
    }
    
    //- (void)davServer:(GCDWebDAVServer*)server didDeleteItemAtPath:(NSString*)path;
    func davServer(_ server: GCDWebDAVServer, didDeleteItemAtPath path: String) {
        DispatchQueue.main.async {
            self.webdavObserver.lastRemovals.append(path)
        }
    }
    
    func davObserver() -> WebDAVObserver {
        return webdavObserver
    }
    
    func applicationDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let path = paths[0]
        return path + "/resources/"
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AC238")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

