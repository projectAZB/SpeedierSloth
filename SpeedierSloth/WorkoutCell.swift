//
//  WorkoutCell.swift
//  SpeedierSloth
//
//  Created by Adam on 5/19/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit

protocol WorkoutCellDelegate : class
{
	func onWorkoutSelected(workout : Workout)
}

class WorkoutCell : UITableViewCell
{
	// MARK : Properties
	
	public static let Identifier = "workout"
	public static let Height : CGFloat = 70.0
	
	public weak var delegate : WorkoutCellDelegate?
	
	private var _workout : Workout!
	
	// MARK : IBOutlets
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!
	
	// MARK : Config
	
	func configure(workout : Workout) {
		_workout = workout
		dateLabel.text = _workout._startDate.toString(dateFormat: DateFormats.MonthDayTime)
		descriptionLabel.text = "\(_workout._workoutType) \(_workout._location)"
		distanceLabel.text = _workout._distance
		durationLabel.text = _workout._duration
	}
	
	// MARK : IBActions
	
	@IBAction func onDisclosurePressed(_ sender: Any) {
		delegate?.onWorkoutSelected(workout: _workout)
	}
	
}
