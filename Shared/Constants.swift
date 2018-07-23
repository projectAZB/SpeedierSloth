//
//  Constants.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/16/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import UIKit

struct Keys {
	//User Defaults Keys
	static let AlarmHour = "alarmHour"
	static let AlarmMinute = "alarmMinute"
	//UNNotification Category Key
	static let AlarmCategory = "workout" //key for category
	//UNNotification Alarm Identifier
	static let AlarmIdentifier = "WorkoutAlarm" //key for identifier
	//UNNotification Alarm Action
	static let AlarmAction = "startWorkoutAction" //key for action
	
	//Keys for WCSession messages
	static let Query = "query"
	static let Response = "response"
	static let WorkoutInProgress = "workoutInProgress"
	static let State = "state"
	static let WorkoutType = "workoutType"
	static let Data = "data"
	static let ToDelete = "toDelete"
	
	//Keys for workout states
	static let Running = "in progress"
	static let Paused = "paused"
	static let Ended = "ended"
	//kind of misc
	static let Marker = "marker"
	
	//Keys for workout types
	static let Run = "run"
	static let Walk = "walk"
	static let Hike = "hike"
}

struct Images {
	static let Running = UIImage(named: "running")!
	static let Walking = UIImage(named: "walking")!
	static let Hiking = UIImage(named: "hiking")!
	static let Marker = UIImage(named: "marker")!
	static let Pause = UIImage(named: "pause")!
	static let Play = UIImage(named: "play")!
	static let Stop = UIImage(named: "stop")!
}

struct DateFormats {
	static let MonthDayTime = "MMM d, h:mm a"
}

struct DataKeys {
	static let WorkoutID = "workoutID"
	static let WorkoutType = "workoutType"
	static let Duration = "duration"
	static let StartDate = "startDate"
	static let EndDate = "endDate"
	static let Energy = "energy"
	static let Distance = "distance"
	static let Location = "location"
	static let AverageBPM = "avgBPM"
	static let Month = "month"
}

extension Notification.Name {
	static let messageReceived : Notification.Name = Notification.Name("messageReceived")
	static let startWorkout : Notification.Name = Notification.Name("startWorkout")
	static let stopWorkout : Notification.Name = Notification.Name("stopWorkout")
	static let pauseWorkout : Notification.Name = Notification.Name("pauseWorkout")
	static let addMarker : Notification.Name = Notification.Name("addMarker")
	static let coreDataUpdate : Notification.Name = Notification.Name("coreDataUpdate")
}
