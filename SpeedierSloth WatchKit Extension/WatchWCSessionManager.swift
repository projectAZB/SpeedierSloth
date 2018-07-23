//
//  WCSessionManager.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import WatchConnectivity
import HealthKit

protocol WatchWCSessionManagerDelegate : class
{
	
}

class WatchWCSessionManager : NSObject
{
	// MARK : Singleton
	
	static let shared : WatchWCSessionManager = WatchWCSessionManager()
	
	private override init() {
		super.init()
		_ = _wcSession
	}
	
	// MARK : Properties
	
	private var _wcSession : WCSession? {
		get {
			let wcSession : WCSession? = WCSession.isSupported() ? WCSession.default : nil
			if let w = wcSession, w.activationState != .activated {
				w.delegate = self
				w.activate()
			}
			return wcSession
		}
	}
	
	public func setWorkoutSession(_ workoutSession : HKWorkoutSession?) {
		_workoutSession = workoutSession
	}
	
	public func workoutSessionInProgress() -> Bool {
		return _workoutSessionInProgress
	}
	
	private var _workoutSession : HKWorkoutSession? {
		didSet {
			if let _ = _workoutSession {
				_workoutSessionInProgress = true
			}
			else {
				_workoutSessionInProgress = false
			}
		}
	}
	
	private var _workoutSessionInProgress : Bool = false {
		didSet {
			if let wcSession = _wcSession {
				if wcSession.isReachable {
					wcSession.sendMessage([Keys.WorkoutInProgress : _workoutSessionInProgress],
										  replyHandler: nil,
										  errorHandler: nil)
				}
				else {
					print("iOS App Not Reachable")
				}
			}
		}
	}
	
	private var _messagesToSend = [[String : Any]]()
	
	// MARK: Utility Methods
	
	public func workoutType() -> String {
		if let type = _workoutSession?.workoutConfiguration.activityType {
			if type == .running {
				return Keys.Run
			}
			else if type == .hiking {
				return Keys.Hike
			}
			else if type == .walking {
				return Keys.Walk
			}
			else {
				print("Invalid type")
				return ""
			}
		}
		else {
			print("No workout session")
			return ""
		}
	}
	
	public func workoutState() -> String {
		if let state = _workoutSession?.state {
			if state == .running {
				return Keys.Running
			}
			else if state == .paused {
				return Keys.Paused
			}
			else {
				return Keys.Ended
			}
		}
		else {
			print("No workout session to get state from")
			return Keys.Ended
		}
	}
	
	func send(message : [String : Any]) {
		guard let wcSession = _wcSession else {
			print("Error sending: no wcsession")
			return
		}
		
		if wcSession.isReachable {
			print("Keys \"\(message.keys)\" sent from send")
			wcSession.sendMessage(message, replyHandler: nil, errorHandler: nil)
		}
		else {
			_messagesToSend.append(message)
		}
	}
	
	private func sendPending() {
		if let session = _wcSession {
			if session.isReachable {
				for message in _messagesToSend {
					print("State \"\(message)\" sent from pending")
					session.sendMessage(message, replyHandler: nil, errorHandler: nil)
				}
				_messagesToSend.removeAll()
			}
		}
	}
}

extension WatchWCSessionManager : WCSessionDelegate
{
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if activationState == .activated {
			sendPending()
		}
	}
	
	func sessionReachabilityDidChange(_ session: WCSession) {
		print(session.activationState)
	}
	
	public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
		guard let query = message[Keys.Query] as? String else {
			print("Bad payload")
			return
		}
		
		if query == Keys.WorkoutInProgress {
			//for when the iOS app polls for the workout session in progress
			replyHandler([Keys.WorkoutInProgress : self._workoutSessionInProgress,
						  Keys.WorkoutType : WatchWCSessionManager.shared.workoutType(),
						  Keys.State : WatchWCSessionManager.shared.workoutState()])
		}
		else if query == Keys.State { //this is more like a POST call
			if let state = message[Keys.State] as? String {
				if state == Keys.Running {
					postNotificationOnMainQueue(name: .startWorkout)
				}
				else if state == Keys.Paused {
					postNotificationOnMainQueue(name: .pauseWorkout)
				}
				else if state == Keys.Marker {
					postNotificationOnMainQueue(name: .addMarker)
				}
				else { //Ended/Not Started
					postNotificationOnMainQueue(name: .stopWorkout)
				}
			}
		}
	}
	
	private func postNotificationOnMainQueue(name : Notification.Name) {
		DispatchQueue.main.async {
			NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
		}
	}
	
}
