//
//  ConfigurationViewController.swift
//  SpeedierSloth
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit
import HealthKit

class ConfigurationViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
	// MARK : Properties
	
	var _selectedActivityType : HKWorkoutActivityType
	
	var _selectedLocationType : HKWorkoutSessionLocationType
	
	let _activityTypes : [HKWorkoutActivityType] = [.walking, .running, .hiking]
	let _locationTypes : [HKWorkoutSessionLocationType] = [.unknown, .indoor, .outdoor]
	
	// MARK : IBOutlets
	
	@IBOutlet var _activityTypePicker : UIPickerView!
	@IBOutlet var _locationTypePicker : UIPickerView!
	
	// MARK : Initialization
	
	required init?(coder aDecoder: NSCoder) {
		_selectedActivityType = _activityTypes[0]
		_selectedLocationType = _locationTypes[0]
		
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.title = "Add Workout"
	}
	
	// MARK : UIPickerViewDelegate
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == _activityTypePicker {
			return format(activityType: _activityTypes[row])
		}
		else if pickerView == _locationTypePicker {
			return format(locationType: _locationTypes[row])
		}
		
		return nil
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == _activityTypePicker {
			_selectedActivityType = _activityTypes[row]
		}
		else {
			_selectedLocationType = _locationTypes[row]
		}
	}
	
	// UIPickerViewDataSource
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == _activityTypePicker {
			return _activityTypes.count
		}
		else if pickerView == _locationTypePicker {
			return _locationTypes.count
		}
		
		return 0
	}
	
	@IBAction func didTapStartButton() {
		let workoutConfiguration = HKWorkoutConfiguration()
		workoutConfiguration.activityType = _selectedActivityType
		workoutConfiguration.locationType = _selectedLocationType
		PhoneWCSessionManager.shared.startWatchApp(configuration: workoutConfiguration)
	}


}

