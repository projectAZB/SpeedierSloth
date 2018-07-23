//
//  Shared.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import HealthKit

extension Date
{
	func toString( dateFormat format  : String ) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}

extension String
{
	func toDate( dateFormat format  : String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		dateFormatter.timeZone = TimeZone.current
		return dateFormatter.date(from: self)!
	}
}

//put here for use in Watch in case iOS app wasn't opened yet
func requestAccessToHealthKit() {
	let healthStore = HKHealthStore()
	
	let allTypes = Set([HKObjectType.workoutType(),
						HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
						HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!,
						HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
						HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
	
	healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
		if !success {
			print(error ?? "Error authorizing health it")
		}
	}
}

func computeDurationOfWorkout(withEvents workoutEvents: [HKWorkoutEvent]?, startDate : Date?, endDate : Date?) -> TimeInterval {
	var duration = 0.0
	
	if var lastDate = startDate {
		var paused = false
		if let events : [HKWorkoutEvent] = workoutEvents {
			for event in events {
				switch event.type
				{
					case .pause:
						duration += event.dateInterval.duration
						paused = true
					case .resume:
						lastDate = event.dateInterval.end
						paused = false
					default:
						continue
				}
			}
		}
		
		if !paused { //add time for last event till now
			if let end = endDate {
				duration += end.timeIntervalSince(lastDate)
			}
			else {
				duration += Date().timeIntervalSince(lastDate)
			}
		}
	}
	
	return duration
}

func format(energy : HKQuantity) -> String {
	return String(format: "%.1f Calories", energy.doubleValue(for: HKUnit.kilocalorie()))
}

func format(distance : HKQuantity) -> String {
	return String(format: "%.1f Meters", distance.doubleValue(for: HKUnit.meter()))
}

func format(heartRate : HKQuantity) -> String {
	return String(format: "%.0f BPM", heartRate.doubleValue(for: HKUnit(from: "count/min")))
}

func format(duration : TimeInterval) -> String {
	let formatter = DateComponentsFormatter()
	formatter.unitsStyle = .positional
	formatter.allowedUnits = [.second, .minute, .hour]
	formatter.zeroFormattingBehavior = .pad
	if let string = formatter.string(from: duration) {
		return string
	}
	else {
		return ""
	}
}

func format(activityType : HKWorkoutActivityType) -> String {
	let formattedType : String
	
	switch activityType
	{
		case .walking:
			formattedType = "Walking"
		case .running:
			formattedType = "Running"
		case .hiking:
			formattedType = "Hiking"
		default:
			formattedType = "Workout"
	}
	
	return formattedType
}

func format(locationType : HKWorkoutSessionLocationType) -> String {
	let formattedType : String
	
	switch locationType
	{
		case .indoor:
			formattedType = "Indoor"
		case .outdoor:
			formattedType = "Outdoor"
		case .unknown:
			formattedType = "Unknown"
	}
	
	return formattedType
}
