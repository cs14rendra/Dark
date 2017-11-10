//
//  AppDelegate.swift
//  Dark
//
//  Created by surendra kumar on 10/5/17.
//  Copyright © 2017 weza. All rights reserved.
// version 2.0

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import UserNotifications
import FirebaseMessaging
import FBSDKCoreKit
import TwitterKit
import GoogleSignIn
import ReachabilitySwift

private let storyBoardName = "Main"
private enum ControllerIdentifre : String{
    case mainpage
    case signUp
}

private let googleURLScheme = "com.googleusercontent.apps.116996367331-4eh5lcviin2b7guog1ps50e7v2rt78tj"
private let twitterURLScheme = "twitterkit-zhP5rll2JCyIc2CokSAfjsWn7"
private let faceBookURLScehme = "fb391961711222053"
let reachability = Reachability()!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        // twitter
        Twitter.sharedInstance().start(withConsumerKey: TWITTERKEY, consumerSecret: TWITTERSECRETE)
        // Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        UserDefaults.standard.register(defaults: [Preferences.Distance.rawValue:10])
        UserDefaults.standard.register(defaults: [Preferences.logIn.rawValue:false])
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainController = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifre.mainpage.rawValue)
        let signUpController = UIStoryboard(name: storyBoardName, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifre.signUp.rawValue)
        if UserDefaults.standard.bool(forKey: Preferences.logIn.rawValue) == true {
                self.window?.rootViewController = mainController
            }else{
                self.window?.rootViewController = signUpController
            }
      
        self.window?.makeKeyAndVisible()
        self.registerForRemoteNotification()
      
        
        do {
            try reachability.startNotifier()
        }catch{
            print("Unable to start notifire")
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
       
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.setUserStatus(isOnline: false)
      
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.setUserStatus(isOnline: true)
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        reachability.stopNotifier()
    }
    
    @available(iOS 9.0,*)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      
        if  url.scheme == googleURLScheme {
               return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,annotation: [:])
        }
        if url.scheme == faceBookURLScehme{
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        }
        if url.scheme == twitterURLScheme{
            return Twitter.sharedInstance().application(app, open: url, options: options)
        }
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme == googleURLScheme{
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: sourceApplication,
                                                     annotation: annotation)
        }
        return false
    }
}

extension AppDelegate {
    func registerForRemoteNotification(){
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions : UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isAuthorise, error in
            }
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        self.suscribeForNews()
    }
    func suscribeForNews(){
        Messaging.messaging().subscribe(toTopic: "News")
    }
    
    func setUserStatus(isOnline : Bool){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let onlineStatusRef : DatabaseReference = REF_USERSTATUS.child(uid).child("online")
        let lastloginREF : DatabaseReference = REF_USERSTATUS .child(uid).child("lastlogin")

        // Considering if user in background, is offline
        if isOnline {
            onlineStatusRef.setValue(isOnline)
            lastloginREF.setValue(Firebase.ServerValue.timestamp())
        }else{
            onlineStatusRef.removeValue()
            lastloginREF.setValue(Firebase.ServerValue.timestamp())
        }
        onlineStatusRef.onDisconnectRemoveValue()
        
        
        lastloginREF.setValue(Firebase.ServerValue.timestamp())
        lastloginREF.onDisconnectSetValue(Firebase.ServerValue.timestamp())
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("recieved")
        let userInfo = response.notification.request.content.userInfo
        if let messgaeID = userInfo["gcm.message_id"]{
            print("Message ID : \(messgaeID)")
        }
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Refreshed FIRToken : \(fcmToken)")
    }
}




