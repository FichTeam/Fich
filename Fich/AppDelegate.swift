//
//  AppDelegate.swift
//  Fich
//
//  Created by Tran Tien Tin on 7/9/17.
//  Copyright © 2017 fichteam. All rights reserved.
//

import UIKit
import Firebase
import Onboard
import CoreLocation

private let kUserHasOnboardedKey: String = "user_has_onboarded"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate{

    var window: UIWindow?
    let locationManager = CLLocationManager.init()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        
        var userHasOnboarded: Bool = UserDefaults.standard.bool(forKey: kUserHasOnboardedKey)
        // if the user has already onboarded, just set up the normal root view controller
        // for the application
        if userHasOnboarded {
            setupNormalRootViewController()
        }else {
            window?.rootViewController = generateOnboard()
        }
        application.statusBarStyle = .lightContent
        window?.makeKeyAndVisible()
        
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
    
    func setupNormalRootViewController() {
        // create whatever your root view controller is going to be, in this case just a simple view controller
        // wrapped in a navigation controller
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"loginViewController")
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        //UserDefaults.standard.set(true, forKey: kUserHasOnboardedKey)
    }
    
    
    func generateOnboard()-> OnboardingViewController{
        let firstPage = OnboardingContentViewController.content(withTitle: "You Want Safe Trips?", body: "This app will help you!", image: UIImage(named: "blue"), buttonText: "Enable Location Services", action: {() -> Void in
            self.requestLocationPermission()
        })
        firstPage.movesToNextViewController = true
        let secondPage = OnboardingContentViewController.content(withTitle: "You're lost out of your team?", body: "This app will keep all you guys together", image: UIImage(named: "red"), buttonText: "Verify your phone number", action: {() -> Void in
            UIAlertView(title: "", message: "Prompt users to do other cool things on startup. As you can see, hitting the action button on the prior page brought you automatically to the next page. Cool, huh?", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
        })
        secondPage.movesToNextViewController = true
        //        secondPage.viewDidAppearBlock = {() -> Void in
        //            UIAlertView(title: "Welcome!", message: "You've arrived on the second page, and this alert was displayed from within the page's viewDidAppearBlock.", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "").show()
        //        }
        
        let thirdPage = OnboardingContentViewController.content(withTitle: "Emergency situation?", body: "This app will notificate to all your trip's member!", image: UIImage(named: "yellow"), buttonText: "Get Started", action: {() -> Void in
            self.handleOnboardingCompletion()
        })
        let onboardingVC = OnboardingViewController.onboard(withBackgroundImage: UIImage(named: "onboard"), contents: [firstPage, secondPage, thirdPage])
        onboardingVC?.shouldFadeTransitions = true
        onboardingVC?.fadePageControlOnLastPage = true
        onboardingVC?.fadeSkipButtonOnLastPage = true
        
        onboardingVC?.allowSkipping = true
        onboardingVC?.skipHandler = {() -> Void in
            self.handleOnboardingCompletion()
        }
        return (onboardingVC)!
    }
    
    func handleOnboardingCompletion(){
        setupNormalRootViewController()
    }
    
    func requestLocationPermission(){
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            if !CLLocationManager.locationServicesEnabled() {
                return
            }
            self.start()
            break
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("エラー:restricted")
            break
            
        }
    }
    func start(){
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }

}

