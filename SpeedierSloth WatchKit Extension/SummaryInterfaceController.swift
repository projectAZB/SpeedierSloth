//
//  SummaryInterfaceController.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/14/18.
//  Copyright © 2018 Adam. All rights reserved.
//
//	Interface controller for the workout summary screen

import WatchKit
import Foundation
import HealthKit

class SummaryInterfaceController: WKInterfaceController
{
	// MARK : Properties
	var _workout : HKWorkout?
	
	let _healthStore : HKHealthStore = HKHealthStore()
	
	// MARK : IB Outlets
	
	@IBOutlet var _workoutLabel : WKInterfaceLabel!
	@IBOutlet var _durationLabel : WKInterfaceLabel!
	@IBOutlet var _caloriesLabel : WKInterfaceLabel!
	@IBOutlet var _distanceLabel : WKInterfaceLabel!
	
	// MARK : Interface Controller Overrides
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		_workout = context as? HKWorkout
		
		setTitle("Summary")
	}
	
	override func willActivate() {
		super.willActivate()
		
		guard let workout = _workout else { return }
		
		_workoutLabel.setText("\(format(activityType: workout.workoutActivityType))")
		_caloriesLabel.setText(format(energy: workout.totalEnergyBurned!))
		_distanceLabel.setText(format(distance: workout.totalDistance!))
		
		let duration = computeDurationOfWorkout(withEvents: workout.workoutEvents,
												startDate: workout.startDate,
												endDate: workout.endDate)
		_durationLabel.setText(format(duration: duration))
	}
	
	// MARK : IBActions
	
	@IBAction func didTapDoneButton() {
		reloadRootPage()
	}
	
	@IBAction func deleteAction() {
		guard let workout = _workout else { return }
		_healthStore.delete(workout) { (success, error) in
			if !success {
				print("Error deleting \(String(describing: error?.localizedDescription))")
			}
		}
		let workoutID : String = UserDefaults.standard.value(forKey: DataKeys.WorkoutID) as? String ?? ""
		var hash : [String : Any] = [String : Any]()
		hash[DataKeys.WorkoutID] = workoutID
		hash[Keys.ToDelete] = true
		WatchWCSessionManager.shared.send(message: [Keys.Data : hash])
		reloadRootPage()
	}
	
	private func reloadRootPage() {
		WKInterfaceController.reloadRootPageControllers(withNames: ["Configuration"],
														contexts: nil,
														orientation: .horizontal,
														pageIndex: 0)
	}
	
}
