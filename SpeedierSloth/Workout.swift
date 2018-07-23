//
//  Workout.swift
//  SpeedierSloth
//
//  Created by Adam on 5/19/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import CoreData

struct Workout
{
	var _workoutID : String
	var _workoutType : String
	var _duration : String
	var _startDate : Date
	var _endDate : Date
	var _energy : String
	var _distance : String
	var _location : String
	var _avgBPM : String
	
	init(hash : [String : Any]) {
		_workoutID = hash[DataKeys.WorkoutID] as? String ?? UUID.init().uuidString
		_workoutType = hash[DataKeys.WorkoutType] as? String ?? "Invalid Type"
		_duration = hash[DataKeys.Duration] as? String ?? "Invalid Duration"
		_startDate = hash[DataKeys.StartDate] as? Date ?? Date()
		_endDate = hash[DataKeys.EndDate] as? Date ?? Date()
		_energy = hash[DataKeys.Energy] as? String ?? "Invalid Energy"
		_distance = hash[DataKeys.Distance] as? String ?? "Invalid Distance"
		_location = hash[DataKeys.Location] as? String ?? "Invalid Location"
		_avgBPM = hash[DataKeys.AverageBPM] as? String ?? "Invalid BPM"
	}
	
	init(managedObject : NSManagedObject)
	{
		_workoutID = managedObject.value(forKey: DataKeys.WorkoutID) as? String ?? UUID.init().uuidString
		_workoutType = managedObject.value(forKey: DataKeys.WorkoutType) as? String ?? "Invalid Type"
		_duration = managedObject.value(forKey: DataKeys.Duration) as? String ?? "Invalid Duration"
		_startDate = managedObject.value(forKey: DataKeys.StartDate) as? Date ?? Date()
		_endDate = managedObject.value(forKey: DataKeys.EndDate) as? Date ?? Date()
		_energy = managedObject.value(forKey: DataKeys.Energy) as? String ?? "Invalid Energy"
		_distance = managedObject.value(forKey: DataKeys.Distance) as? String ?? "Invalid Distance"
		_location = managedObject.value(forKey: DataKeys.Location) as? String ?? "Invalid Location"
		_avgBPM = managedObject.value(forKey: DataKeys.AverageBPM) as? String ?? "Invalid BPM"
	}
	
	func populateManagedObject(managedObject : NSManagedObject)
	{
		managedObject.setValue(_workoutID, forKey: DataKeys.WorkoutID)
		managedObject.setValue(_workoutType, forKey: DataKeys.WorkoutType)
		managedObject.setValue(_duration, forKey: DataKeys.Duration)
		managedObject.setValue(_startDate, forKey: DataKeys.StartDate)
		managedObject.setValue(_endDate, forKey: DataKeys.EndDate)
		managedObject.setValue(_energy, forKey: DataKeys.Energy)
		managedObject.setValue(_distance, forKey: DataKeys.Distance)
		managedObject.setValue(_location, forKey: DataKeys.Location)
		managedObject.setValue(_avgBPM, forKey: DataKeys.AverageBPM)
		managedObject.setValue(monthDateFromStartDate(), forKey: DataKeys.Month)
	}
	
	private func monthDateFromStartDate() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "LLL"
		return formatter.string(from: _startDate)
	}
}
