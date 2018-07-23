//
//  AppDelegate.swift
//  SpeedierSloth
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
import WatchConnectivity

struct StoryboardIDs {
	static let workoutVC = "workout"
	static let listVC = "list"
	static let addVC = "add"
	static let rootVC = "root"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		requestAccessToHealthKit()
		PhoneWCSessionManager.shared.delegate = self
		CoreDataManager.shared.delegate = self
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		print(urls[urls.count-1] as URL)
		return true
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		CoreDataManager.shared.saveContext()
	}
}

extension AppDelegate
{
	// MARK : Convenience Methods
	
	private func showWorkoutViewController(payload : [String : Any]) {
		showViewController(storyboardID: StoryboardIDs.workoutVC, payload : payload)
	}
	
	func showListViewController() {
		showViewController(storyboardID: StoryboardIDs.rootVC, payload : nil)
	}
	
	private func showViewController(storyboardID : String, payload : [String : Any]?) {
		guard let window = UIApplication.shared.keyWindow,
			let rootViewController = window.rootViewController else {
				print("No window or root view controller")
				return
		}
		let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: storyboardID)
		vc.view.frame = rootViewController.view.frame
		vc.view.layoutIfNeeded()
		
		if let message = payload, let workoutVC = vc as? WorkoutViewController {
			workoutVC.userInfo = message
		}
		
		UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
			window.rootViewController = vc
		}, completion: { completed in
			window.makeKeyAndVisible()
		})
	}
}

extension AppDelegate : CoreDataManagerDelegate
{
	func onCoreDataUpdate() {
		//send out notification
		NotificationCenter.default.post(name: .coreDataUpdate, object: nil, userInfo: nil)
	}
}

extension AppDelegate : PhoneWCSessionManagerDelegate
{
	// MARK : Convenience
	
	fileprivate func handle(message : [String : Any]) {
		guard let root = self.window?.rootViewController else {
			print("No root init'ed yet")
			return
		}
		guard let workoutInProgress = message[Keys.WorkoutInProgress] as? Bool else {
			print("Invalid workInProgress from message")
			return
		}
		if workoutInProgress {
			guard let _ = root as? WorkoutViewController else {
				showWorkoutViewController(payload: message)
				return
			}
			//workout view controller already the root
		}
		else {
			guard let _ = root as? UINavigationController else {
				showListViewController()
				return
			}
			//List view is already the root
		}
	}
	
	// MARK : PhoneWCSessionManagerDelegate
	
	func onMessageReceived(message: [String : Any]) {
		if let _ = message[Keys.WorkoutInProgress] as? Bool,
			let _ = message[Keys.State] as? String,
			let _ = message[Keys.WorkoutType] as? String { //handle workout in progress
			handle(message: message)
		}
		if let _ = message[Keys.State] as? String, let _ = message[Keys.WorkoutType] { //handle state message
			NotificationCenter.default.post(name: .messageReceived, object: nil, userInfo: message)
		}
		else if let hash = message[Keys.Data] as? [String : Any] {
			guard let toDelete : Bool = hash[Keys.ToDelete] as? Bool else {
				print("No to delete message")
				return
			}
			if toDelete {
				guard let workoutID : String = hash[DataKeys.WorkoutID] as? String else {
					print("Invalid workout ID in hash")
					return
				}
				CoreDataManager.shared.delete(workoutID: workoutID)
			}
			else {
				CoreDataManager.shared.save(workoutHash: hash)
			}
		}
	}
	
	func onSessionStateChanged(active: Bool) {
		let message : String = active ? "Activated" : "Deactivated"
		print("Session \(message)")
		if active {
			PhoneWCSessionManager.shared.checkForWorkoutInProgress()
		}
	}
	
	func launchWorkoutViewController() {
		showWorkoutViewController(payload: [Keys.WorkoutInProgress : true])
	}
}
