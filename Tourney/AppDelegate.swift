//
//  AppDelegate.swift
//  Tourney
//
//  Created by Will Cohen on 7/29/19.
//  Copyright © 2019 Will Cohen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

// I can create an account with nothing in the email and password field right now
    // FIX THIS
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("configured!")
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Universal Link Handler
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let incomingURL = userActivity.webpageURL {
            print("incoming url: \(incomingURL)")
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamiclink, error) in
                guard error == nil else {
                    print("found error parsing universal link: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let link = dynamiclink {
                    self.handleIncomingDynamicLink(link)
                }
            }
            return handled
        } else {
            return false
        }
        
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let dynamicLinkURL = dynamicLink.url else {
            print("dynamic link received contains no URL object")
            return
        }
        
        print("incoming dynamic link url: \(dynamicLinkURL)")
        
        guard let urlComponents = URLComponents(url: dynamicLinkURL, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems else { return }
        
        print("found \(queryItems.count) query items for dynamic link:")
        queryItems.forEach({
            print("key: \($0.name)")
            print("value: \($0.value)")
        })
        
        
        if let launchVC = self.window?.rootViewController as? FirstViewController,
            let dynamicLinkTourneyId = queryItems[0].value {
            
            if Auth.auth().currentUser != nil {
                // logged in and already loaded from prior open
                if let mainTournamentPage = launchVC.presentedViewController as? TableViewController {
                    mainTournamentPage.dynamicLinkTourneyIdForReturningUsers = dynamicLinkTourneyId
                } else {
                    // logged in but app was closed (????)
                    launchVC.dynamicLinkTourneyId = dynamicLinkTourneyId
                }
            } else {
                if let signUpPage = launchVC.presentedViewController as? UserVC {
                    // not logged in but already tapped signup
                    signUpPage.dynamicLinkTourneyId = dynamicLinkTourneyId
                } else if let loginPage = launchVC.presentedViewController as? LoginVC {
                    // not logged in but already tapped sign in
                    loginPage.dynamicLinkTourneyId = dynamicLinkTourneyId
                } else {
                    // not logged in and has not tapped sign up or sign in
                    launchVC.dynamicLinkTourneyId = dynamicLinkTourneyId
                }
            }
        }
        
    }
    
    // MARK: - Custom URL Link Handler
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        } else {
            return false
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Tourney")
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

