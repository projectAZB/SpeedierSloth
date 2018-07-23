//
//  AlarmInterfaceController.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/16/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import WatchKit
import Foundation


class AlarmInterfaceController: WKInterfaceController
{
	// MARK : Properties
	private lazy var _selectedHour : Int = {
		return UserDefaults.standard.integer(forKey: Keys.AlarmHour)
	}()
	
	private lazy var _selectedMinute : Int = {
		return UserDefaults.standard.integer(forKey: Keys.AlarmMinute)
	}()
	
	private lazy var _hours : [String] = {
		var hours : [String] = [String]()
		for i in 0..<24 {
			let value = i < 10 ? "0\(i)" : "\(i)"
			hours.append(value)
		}
		return hours
	}()
	
	private lazy var _minutes : [String] = {
		var minutes : [String] = [String]()
		for i in 0..<60 {
			let value = i < 10 ? "0\(i)" : "\(i)"
			minutes.append(value)
		}
		return minutes
	}()
	
	// MARK : IBOutlets
	
	@IBOutlet var hourPicker: WKInterfacePicker!
	@IBOutlet var minutePicker: WKInterfacePicker!
	
	// MARK : IBActions
	
	@IBAction func hourPickerChanged(_ value: Int) {
		_selectedHour = value
	}
	
	
	@IBAction func minutePickerChanged(_ value: Int) {
		_selectedMinute = value
	}
	
	@IBAction func setButtonTapped() {
		
		guard let delegate : ExtensionDelegate = WKExtension.shared().delegate as? ExtensionDelegate else {
			print("Delegate nil")
			return
		}
		var date = DateComponents()
		date.hour = _selectedHour
		date.minute = _selectedMinute
		delegate.addLocalNotification(date: date)
		reloadRootPage()
	}

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // populate hour picker
		let hourPickerItems : [WKPickerItem] = _hours.map { (hour) -> WKPickerItem in
			let pickerItem = WKPickerItem()
			pickerItem.title = hour
			return pickerItem
		}
		hourPicker.setItems(hourPickerItems)
		hourPicker.setSelectedItemIndex(_selectedHour)
		
		//populate minute picker
		let minutePickerItems : [WKPickerItem] = _minutes.map { (minute) -> WKPickerItem in
			let pickerItem = WKPickerItem()
			pickerItem.title = minute
			return pickerItem
		}
		minutePicker.setItems(minutePickerItems)
		minutePicker.setSelectedItemIndex(_selectedMinute)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
	
	private func reloadRootPage() {
		WKInterfaceController.reloadRootPageControllers(withNames: ["Configuration"],
														contexts: nil,
														orientation: .horizontal,
														pageIndex: 0)
	}

}
