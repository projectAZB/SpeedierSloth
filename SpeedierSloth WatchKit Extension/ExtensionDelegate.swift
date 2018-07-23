//
//  ExtensionDelegate.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import WatchKit
import HealthKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate {
	
	private lazy var _center = {
		return UNUserNotificationCenter.current()
	}()

    func applicationDidFinishLaunching() {
		_center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
			if !granted {
				print("Notification support not granted")
			}
			else {
				self._center.delegate = self
				self._center.getPendingNotificationRequests(completionHandler: { (requests) in
					print("Count \(requests.count)")
					if requests.count == 0 { //if no notification exists, create default at 6am
						var date = DateComponents()
						date.hour = 6
						date.minute = 0
						self.addLocalNotification(date: date)
					}
				})
			}
		}
		//in case iOS app wasn't opened yet to give access
		requestAccessToHealthKit()
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
	
	func addLocalNotification(date : DateComponents) {
		let content = UNMutableNotificationContent()
		content.title = "Workout!"
		content.body = "It's time for your daily workout"
		content.sound = UNNotificationSound.default()
		content.categoryIdentifier = Keys.AlarmCategory
		
		let action = UNNotificationAction(identifier: Keys.AlarmAction,
										  title: "Start Workout",
										  options: .foreground)
		let category = UNNotificationCategory(identifier: Keys.AlarmCategory,
											  actions: [action],
											  intentIdentifiers: [],
											  options: [])
		_center.setNotificationCategories([category])
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: date,
													repeats: true)
		let request = UNNotificationRequest(identifier: Keys.AlarmIdentifier,
											content: content,
											trigger: trigger)
		_center.add(request, withCompletionHandler: { (error) in
			if let _ = error {
				print(error!.localizedDescription)
			}
			else {
				print("Workout notification at \(date.hour!):\(date.minute!) set")
				//save to user defaults
				UserDefaults.standard.set(date.hour!, forKey: Keys.AlarmHour)
				UserDefaults.standard.set(date.minute!, forKey: Keys.AlarmMinute)
			}
		})
	}
	
	func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
		guard !WatchWCSessionManager.shared.workoutSessionInProgress() else {
			print("Workout already in progress")
			return
		}
		
		WKInterfaceController.reloadRootPageControllers(withNames: ["Workout"],
														contexts: [workoutConfiguration],
														orientation: .horizontal,
														pageIndex: 0)
	}

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks
		{
            // Use a switch statement to check the task type
            switch task
			{
				case let backgroundTask as WKApplicationRefreshBackgroundTask:
					// Be sure to complete the background task once you’re done.
					backgroundTask.setTaskCompletedWithSnapshot(false)
				case let snapshotTask as WKSnapshotRefreshBackgroundTask:
					// Snapshot tasks have a unique completion call, make sure to set your expiration date
					snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
				case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
					// Be sure to complete the connectivity task once you’re done.
					connectivityTask.setTaskCompletedWithSnapshot(false)
				case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
					// Be sure to complete the URL session task once you’re done.
					urlSessionTask.setTaskCompletedWithSnapshot(false)
				default:
					// make sure to complete unhandled task types
					task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}

extension ExtensionDelegate : UNUserNotificationCenterDelegate
{
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		if response.notification.request.content.categoryIdentifier == Keys.AlarmCategory {
			if response.actionIdentifier == Keys.AlarmAction {
				let workoutConfig : HKWorkoutConfiguration = HKWorkoutConfiguration()
				workoutConfig.activityType = .running
				workoutConfig.locationType = .unknown
				handle(workoutConfig)
			}
		}
		completionHandler()
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
	}
}
