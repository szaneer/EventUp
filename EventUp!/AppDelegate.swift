//
//  AppDelegate.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/5/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if Auth.auth().currentUser != nil {
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! UITabBarController
            
            if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
                // 2
                let aps = notification["aps"] as! [String: AnyObject]
                print(aps)
                
            }
            
            window?.rootViewController = mainViewController
        }
        registerForPushNotifications()
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
        }
        
        func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
            
            return handled
        }
        
        func registerForPushNotifications() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        }
        
        func getNotificationSettings() {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.sync {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        }
        
        func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data -> String in
                return String(format: "%02.2hhx", data)
            }
            
            let token = tokenParts.joined()
            if let user = Auth.auth().currentUser {
                EventUpClient.sharedInstance.setNotificationToken(uid: user.uid, token: token, success: {
                    print("Set token in database")
                }, failure: { (error) in
                    print(error.localizedDescription)
                })
            }
            print("Device Token: \(token)")
        }
        
        func application(_ application: UIApplication,
                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register: \(error)")
        }
}

