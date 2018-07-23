//
//  DetailViewController.swift
//  SpeedierSloth
//
//  Created by Adam on 5/19/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit

class DetailViewController: BaseViewController
{
	// MARK : IBOutlets
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var startLabel: UILabel!
	@IBOutlet weak var endLabel: UILabel!
	@IBOutlet weak var caloriesLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var bpmLabel: UILabel!
	
	
	// MARK : Properties
	
	public var _workout : Workout!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		typeLabel.text = _workout._workoutType
		durationLabel.text = _workout._duration
		startLabel.text = _workout._startDate.toString(dateFormat: DateFormats.MonthDayTime)
		endLabel.text = _workout._endDate.toString(dateFormat: DateFormats.MonthDayTime)
		caloriesLabel.text = _workout._energy
		distanceLabel.text = _workout._distance
		locationLabel.text = _workout._location
		bpmLabel.text = _workout._avgBPM
    }
	
	@IBAction func onDeletePressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
		CoreDataManager.shared.delete(workoutID: _workout._workoutID)
	}
	

}
