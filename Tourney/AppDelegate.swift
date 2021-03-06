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
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging


import IQKeyboardManagerSwift

extension Notification.Name {
	static let signOutNotification = Notification.Name("signOutNotification")
	static let signedInNotification = Notification.Name("signedInNotification")
}
  
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    let gcmMessageIDKey = "gcmMessage_ID"

    var window: UIWindow?

// I can create an account with nothing in the email and password field right now
    // FIX THIS
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        
        IQKeyboardManager.shared.enable = true

        // handle dynamic link when app is switching from inactive to active state
        if let userActivityDictionary = launchOptions?[.userActivityDictionary] as? [UIApplication.LaunchOptionsKey : Any],
            let userActivity = userActivityDictionary[.userActivityType] as? NSUserActivity {
            handleUserActivity(userActivity: userActivity)
        }
		
		NotificationCenter.default.addObserver(self, selector: #selector(signOutAction(_:)), name: .signOutNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(signedInAction(_:)), name: .signedInNotification, object: nil)
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        return true
    }
	
	@objc func signOutAction(_ notification: Notification) {
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpLogInVC")
	}
    
	@objc func signedInAction(_ notification: Notification) {
        
        // If the user is anonoymous 
        
        let afterLoginNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AfterLoginNavigationController") as! UINavigationController
        if let dynamicLinkTourneyId = notification.userInfo?["dynamicLinkTourneyId"] as? String, !dynamicLinkTourneyId.isEmpty {
            let featuredChannelsVC = afterLoginNavigationController.viewControllers.first as? FeaturedChannelsTableViewController
            featuredChannelsVC?.dynamicLinkTourneyId = dynamicLinkTourneyId
        }
        window?.rootViewController = afterLoginNavigationController
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
    func handleUserActivity(userActivity: NSUserActivity) {
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
        
        guard let dynamicLinkTourneyId = queryItems[0].value else { return }
        
        if let signUpLogInVC = window?.rootViewController as? SignUpLogInVC {
            // not signed in, set dynamic link var at approproate VC (depending on where user is when dynamic link is parsed from network)
            if let signUpPage = signUpLogInVC.presentedViewController as? SignUpVC {
                // not logged in but already tapped signup
                signUpPage.dynamicLinkTourneyId = dynamicLinkTourneyId
            } else if let loginPage = signUpLogInVC.presentedViewController as? LoginVC {
                // not logged in but already tapped sign in
                loginPage.dynamicLinkTourneyId = dynamicLinkTourneyId
            } else {
                // not logged in and has not tapped sign up or sign in
                signUpLogInVC.dynamicLinkTourneyId = dynamicLinkTourneyId
            }
        } else if let navigationController = window?.rootViewController as? UINavigationController {
            (navigationController.viewControllers.first as? FeaturedChannelsTableViewController)?.dynamicLinkTourneyId = dynamicLinkTourneyId
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
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    func application(_ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken;
    }
}



 
