//
//  ConfigurationInterfaceController.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class ConfigurationInterfaceController: WKInterfaceController
{
	// MARK : Properties
	
	var _selectedActivityType : HKWorkoutActivityType
	var _selectedLocationType : HKWorkoutSessionLocationType
	
	let _activityTypes : [HKWorkoutActivityType] = [.walking, .running, .hiking]
	let _locationTypes : [HKWorkoutSessionLocationType] = [.unknown, .indoor, .outdoor]
	
	// Mark : IBOutlets
	
	@IBOutlet var _activityTypePicker : WKInterfacePicker!
	@IBOutlet var _locationTypePicker : WKInterfacePicker!
	
	override init() {
		_selectedActivityType = _activityTypes[0]
	    _selectedLocationType = _locationTypes[0]
		
		super.init()
	}

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		//populate the activity type picker
		let activityTypePickerItems : [WKPickerItem] = _activityTypes.map { (type) -> WKPickerItem in
			let pickerItem = WKPickerItem()
			pickerItem.title = format(activityType: type)
			return pickerItem
		}
		_activityTypePicker.setItems(activityTypePickerItems)
		
		//populate the location type picker
		let locationTypePickerItems : [WKPickerItem] = _locationTypes.map { (type) -> WKPickerItem in
			let pickerItem = WKPickerItem()
			pickerItem.title = format(locationType: type)
			return pickerItem
		}
		_locationTypePicker.setItems(locationTypePickerItems)
		
		setTitle("Speedier Sloth")
    }
	
	// MARK : IBActions
	
	@IBAction func activityTypePickerSelectedItemChanged(value : Int) {
		_selectedActivityType = _activityTypes[value]
	}
	
	@IBAction func locationTypePickerSelectedItemChanged(value : Int) {
		_selectedLocationType = _locationTypes[value]
	}
	
	@IBAction func didTapStartButton() {
		//Create workout configuration
		let workoutConfiguration = HKWorkoutConfiguration()
		workoutConfiguration.activityType = _selectedActivityType
		workoutConfiguration.locationType = _selectedLocationType
		
		//pass configuration to next interface
		WKInterfaceController.reloadRootPageControllers(withNames: ["Workout"], contexts: [workoutConfiguration], orientation: .horizontal, pageIndex: 0)
	}
	
	@IBAction func alarmTapped() {
		WKInterfaceController.reloadRootPageControllers(withNames: ["Alarm"],
														contexts: nil,
														orientation: .horizontal,
														pageIndex: 0)
	}
	

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
