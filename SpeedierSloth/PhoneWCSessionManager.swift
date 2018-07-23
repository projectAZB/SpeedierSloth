//
//  WCSessionManager.swift
//  SpeedierSloth
//
//  Created by Adam on 5/18/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import WatchConnectivity
import HealthKit

protocol PhoneWCSessionManagerDelegate : class
{
	func onMessageReceived(message : [String : Any])
	func onSessionStateChanged(active : Bool)
	func launchWorkoutViewController()
}

class PhoneWCSessionManager : NSObject  {
	
	// MARK : Singleton
	
	static let shared = PhoneWCSessionManager()
	
	private override init() {
		super.init()
		_ = _wcSession
	}
	
	// MARK : Properties
	
	public weak var delegate : PhoneWCSessionManagerDelegate? //always need to be called on main queue
	
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
	
	private let _healthStore = HKHealthStore()
	
	// MARK : Convenience
	
	func startWatchApp(configuration : HKWorkoutConfiguration?) {
		guard let workoutConfiguration = configuration else { return }
		
		guard let wcSession = _wcSession else {
			print("No wcSession")
			//assert(false)
			return
		}
		
		if wcSession.isWatchAppInstalled && wcSession.activationState == .activated  {
			self._healthStore.startWatchApp(with: workoutConfiguration, completion: { (success, error) in
				//handle errors
				if !success {
					print(error?.localizedDescription ?? "Error starting watch app")
				}
				else {
					if wcSession.isReachable {
						DispatchQueue.main.async {
							[weak self] in
							guard let strongSelf = self else { return }
							strongSelf.delegate?.launchWorkoutViewController()
							strongSelf.checkForWorkoutInProgress()
						}
					}
				}
			})
		}
		else {
			print("Wrong activation State : \(wcSession.activationState)")
		}
	}
	
	func checkForWorkoutInProgress() {
		guard let wcSession = _wcSession, wcSession.activationState == .activated, wcSession.isReachable else {
			print("WCSession doesn't exist/not activated/not reachable")
			DispatchQueue.main.async {
				self.delegate?.onMessageReceived(message: [Keys.WorkoutInProgress : false])
			}
			return
		}
		
		wcSession.sendMessage([Keys.Query : Keys.WorkoutInProgress],
							  replyHandler: { (reply : [String : Any]) in
								DispatchQueue.main.async {
									[weak self] in
									guard let strongSelf = self else { return }
									strongSelf.delegate?.onMessageReceived(message: reply)
								}
								
		},
							  errorHandler: nil)
	}
	
	func signalWorkout(state : String) {
		guard let wcSession = _wcSession, wcSession.activationState == .activated, wcSession.isReachable else {
			print("WCSession doesn't exist/not activated/not reachable")
			DispatchQueue.main.async {
				self.delegate?.onMessageReceived(message: [Keys.WorkoutInProgress : false])
			}
			return
		}
		
		wcSession.sendMessage([Keys.Query : Keys.State, Keys.State : state],
							  replyHandler: { (reply : [String : Any]) in
								DispatchQueue.main.async {
									[weak self] in
									guard let strongSelf = self else { return }
									strongSelf.delegate?.onMessageReceived(message: reply)
								}
		},
							  errorHandler: nil)
	}
	
}

extension PhoneWCSessionManager : WCSessionDelegate
{
	//iOS only WCSessionDelegate methods
	func sessionDidBecomeInactive(_ session: WCSession) {
		//
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		//
	}
	
	//Called when WCSession activation state is changed
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if let _ = error {
			print("Activation error \(error!.localizedDescription)")
			return
		}
	}
	
	//Called when WCSession reachbility is changed
	func sessionReachabilityDidChange(_ session: WCSession) {
		let active : Bool = session.activationState == .activated ? true : false
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf.delegate?.onSessionStateChanged(active: active)
		}
	}
	
	// MARK : WCSessionDelegate
	
	func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf.delegate?.onMessageReceived(message: message)
		}
	}
	
}
