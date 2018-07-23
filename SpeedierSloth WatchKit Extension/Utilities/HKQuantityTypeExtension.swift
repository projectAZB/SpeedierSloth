//
//  HKQuantityTypeExtension.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import HealthKit

extension HKQuantityType
{
	static func distanceWalkingRunning() -> HKQuantityType {
		return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
	}
	
	static func distanceCycling() -> HKQuantityType {
		return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!
	}
	
	static func activeEnergyBurned() -> HKQuantityType {
		return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
	}
	
	static func heartRate() -> HKQuantityType {
		return HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
	}
	
}
