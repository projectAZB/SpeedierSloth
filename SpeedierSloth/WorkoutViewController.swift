//
//  WorkoutViewController.swift
//  SpeedierSloth
//
//  Created by Adam on 5/14/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class WorkoutViewController: BaseViewController
{
	@IBOutlet var workoutSessionState : UILabel!
	@IBOutlet weak var workoutImageView: UIImageView!
	@IBOutlet weak var playPauseButton: UIButton!
	
	// MARK : Properties
	
	public var userInfo : [String : Any]?
	
	private var _isPaused = false {
		didSet {
			if _isPaused {
				self.playPauseButton.setImage(Images.Play, for: .normal)
			}
			else {
				self.playPauseButton.setImage(Images.Pause, for: .normal)
			}
		}
	}
	
	// MARK : UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if let payload = userInfo {
			handle(userInfo: payload)
		}
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(onMessageReceived(_:)),
											   name: .messageReceived,
											   object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self,
												  name: .messageReceived,
												  object: nil)
	}
	
	@objc func onMessageReceived(_ notification : NSNotification) {
		guard let userInfo = notification.userInfo as? [String : Any] else {
			print("Notification message wrong format")
			return
		}
		handle(userInfo: userInfo)
	}
	
	// MARK : IBActions
	
	@IBAction func onStopPressed(_ sender: Any) {
		PhoneWCSessionManager.shared.signalWorkout(state: Keys.Ended)
	}
	
	@IBAction func onPlayPausePressed(_ sender: Any) {
		if (_isPaused) {
			_isPaused = false
			PhoneWCSessionManager.shared.signalWorkout(state: Keys.Running)
		}
		else { //is running, pause it
			_isPaused = true
			PhoneWCSessionManager.shared.signalWorkout(state: Keys.Paused)
		}
	}
	
	@IBAction func onMarkerPressed(_ sender: Any) {
		PhoneWCSessionManager.shared.signalWorkout(state: Keys.Marker)
	}
	
	
	// MARK : Convenience
	
	private func handle(userInfo : [String : Any]) {
		if let state = userInfo[Keys.State] as? String {
			self.workoutSessionState.text = state
			if state == Keys.Paused {
				_isPaused = true
			}
			else if state == Keys.Running {
				_isPaused = false
			}
			else {
				if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
					appDelegate.showListViewController() //present the normal UI
				}
				else {
					print("App Delegate doesn't exist!")
					//assert(false)
				}
			}
		}
		if let type = userInfo[Keys.WorkoutType] as? String {
			if type == Keys.Run {
				workoutImageView.image = Images.Running
			}
			else if type == Keys.Walk {
				workoutImageView.image = Images.Walking
			}
			else if type == Keys.Hike {
				workoutImageView.image = Images.Hiking
			}
			else {
				//print("Invalid Key String provided for workout type: \(type)")
			}
		}
	}
}
