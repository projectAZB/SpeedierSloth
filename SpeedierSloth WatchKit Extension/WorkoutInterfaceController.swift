//
//  WorkoutInterfaceController.swift
//  SpeedierSloth WatchKit Extension
//
//  Created by Adam on 5/13/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate
{
	// MARK : Properties
	
	let _healthStore : HKHealthStore = HKHealthStore()
	
	var _workoutSession : HKWorkoutSession?
	
	var _activeDataQueries = [HKQuery]()
	
	var _workoutStartDate : Date?
	
	var _workoutEndDate : Date?
	
	var _totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0)
	
	var _totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 0)
	
	var _bpm = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 0)
	
	var _avgBPM : HKQuantity {
		if _heartRates.count == 0 { return HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: 0.0) }
		let avg : Double = _heartRates.reduce(0, +) / Double(_heartRates.count)
		return HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: avg)
	}
	
	var _workoutEvents = [HKWorkoutEvent]()
	
	var _timer : Timer?
	
	var _isPaused = false
	
	var _heartRates : [Double] = [Double]()
	
	var _notifying : Bool = false
	
	var _workoutHash : [String : Any] = [String : Any]()
	
	// MARK : IBOutlets
	
	@IBOutlet var _durationLabel : WKInterfaceLabel!
	
	@IBOutlet var _caloriesLabel : WKInterfaceLabel!
	
	@IBOutlet var _distanceLabel : WKInterfaceLabel!
	
	@IBOutlet var _pauseResumeButton : WKInterfaceButton!
	
	@IBOutlet var _bpmLabel : WKInterfaceLabel!
	
	// MARK : INTERFACE CONTROLLER OVERRIDES
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		//start a workout session with the configuration
		if let workoutConfiguration = context as? HKWorkoutConfiguration {
			do {
				_workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
				_workoutSession?.delegate = self
				
				_workoutStartDate = Date()
				
				_healthStore.start(_workoutSession!)
				WatchWCSessionManager.shared.setWorkoutSession(_workoutSession!)
			}
			catch {
				print("Error configuring workout session")
			}
		}
		
		//register for notifications
		NotificationCenter.default.addObserver(self, selector: #selector(stopSession), name: .stopWorkout, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(resumeSession), name: .startWorkout, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pauseSession), name: .pauseWorkout, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(addMarker), name: .addMarker, object: nil)
	}
	
	override func didDeactivate() {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK : Notifcation selectors
	
	@objc func stopSession() {
		guard let workoutSession = _workoutSession else { return }
		endWorkout(workoutSession)
	}
	
	@objc func resumeSession() {
		guard let workoutSession = _workoutSession else { return }
		_healthStore.resumeWorkoutSession(workoutSession)
	}
	
	@objc func pauseSession() {
		guard let workoutSession = _workoutSession else { return }
		_healthStore.pause(workoutSession)
	}
	
	@objc func addMarker() {
		addNewMarker()
	}
	
	// MARK : Totals
	
	private func totalCalories() -> Double {
		return _totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
	}
	
	private func totalMeters() -> Double {
		return _totalDistance.doubleValue(for: HKUnit.meter())
	}
	
	private func setTotalCalories(calories : Double) {
		_totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories)
	}
	
	private func setTotalMeters(meters : Double) {
		_totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: meters)
	}
	
	private func setBPM(bpm : Double) {
		_heartRates.append(bpm)
		_bpm = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: bpm)
	}
	
	// MARK : IB Actions
	
	@IBAction func didTapPauseResumeButton() {
		if let session = _workoutSession {
			switch session.state
			{
				case .running:
					_healthStore.pause(session)
				case .paused:
					_healthStore.resumeWorkoutSession(session)
				default:
					break
			}
		}
	}
	
	@IBAction func didTapStopButton() {
		endWorkout(_workoutSession!)
	}
	
	private func endWorkout(_ workout : HKWorkoutSession) {
		_workoutEndDate = Date()
		//end the workout session
		_healthStore.end(_workoutSession!)
		WatchWCSessionManager.shared.setWorkoutSession(nil)
	}
	
	@IBAction func didTapMarkerButton() {
		addNewMarker()
	}
	
	private func addNewMarker() {
		if !_isPaused {
			let markerEvent = HKWorkoutEvent(type: .marker, dateInterval: DateInterval(start: _workoutStartDate!, duration: 0), metadata: nil)
			_workoutEvents.append(markerEvent)
			notifyEvent(markerEvent)
		}
	}
	
	// MARK : Convenience
	
	func updateLabels() {
		
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self, !strongSelf._isPaused else { return }
			if (!strongSelf._notifying) {
				let duration = computeDurationOfWorkout(withEvents: strongSelf._workoutEvents, startDate: strongSelf._workoutStartDate, endDate: strongSelf._workoutEndDate)
				strongSelf._durationLabel.setText(format(duration: duration))
			}
			strongSelf._caloriesLabel.setText(format(energy: strongSelf._totalEnergyBurned))
			strongSelf._distanceLabel.setText(format(distance: strongSelf._totalDistance))
			strongSelf._bpmLabel.setText(format(heartRate: strongSelf._bpm))
		}
	}
	
	func updateState() {
		DispatchQueue.main.async {
			if let session = self._workoutSession {
				switch session.state
				{
					case .running:
						self.setTitle("Active Workout")
						WatchWCSessionManager.shared.send(message: [Keys.State : Keys.Running,
																	Keys.WorkoutType : WatchWCSessionManager.shared.workoutType()])
						self._pauseResumeButton.setTitle("Pause")
					case .paused:
						self.setTitle("Paused Workout")
						WatchWCSessionManager.shared.send(message: [Keys.State : Keys.Paused,
																	Keys.WorkoutType : WatchWCSessionManager.shared.workoutType()])
						self._pauseResumeButton.setTitle("Resume")
					case .notStarted, .ended:
						self.setTitle("Workout")
						WatchWCSessionManager.shared.send(message: [Keys.State : Keys.Ended,
																	Keys.WorkoutType : WatchWCSessionManager.shared.workoutType()])
				}
			}
		}
	}
	
	func notifyEvent(_ : HKWorkoutEvent) {
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf._notifying = true
			strongSelf._durationLabel.setText("Marker Saved!") //use this instead of wasting space w/ marker label
			WKInterfaceDevice.current().play(.notification)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
				[weak self] in
				guard let strongSelf = self else { return }
				strongSelf._notifying = false
				strongSelf.updateLabels()
			})
		}
	}
	
	// MARK: Data Queries
	
	func startAccumulatingData(startDate: Date) {
		startQuery(quantityTypeIdentifier: .distanceWalkingRunning)
		startQuery(quantityTypeIdentifier: .activeEnergyBurned)
		startQuery(quantityTypeIdentifier: .heartRate)
		
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf.startTimer()
		}
	}
	
	func startQuery(quantityTypeIdentifier : HKQuantityTypeIdentifier) {
		
		let datePredicate = HKQuery.predicateForSamples(withStart: _workoutStartDate,
														end: nil,
														options: .strictStartDate)
		let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
		let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
		let updateHandler : ((HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void) = { query, samples, deletedObjects, queryAnchor, error in
			if let _ = error {
				print(error!.localizedDescription)
			}
			self.process(samples: samples,
						 quantityTypeIdentifier: quantityTypeIdentifier)
		}
		
		let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
										  predicate: queryPredicate,
										  anchor: nil,
										  limit: HKObjectQueryNoLimit,
										  resultsHandler: updateHandler)
		query.updateHandler = updateHandler
		_healthStore.execute(query)
		
		_activeDataQueries.append(query)
	}
	
	func process(samples : [HKSample]?, quantityTypeIdentifier: HKQuantityTypeIdentifier) {
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self, !strongSelf._isPaused else { return }
			
			if let quantitySamples = samples as? [HKQuantitySample] {
				for sample in quantitySamples {
					if quantityTypeIdentifier == .distanceWalkingRunning {
						let newMeters : Double = sample.quantity.doubleValue(for: HKUnit.meter())
						strongSelf.setTotalMeters(meters: strongSelf.totalMeters() + newMeters)
					}
					else if quantityTypeIdentifier == .activeEnergyBurned {
						let newKCal : Double = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
						strongSelf.setTotalCalories(calories: strongSelf.totalCalories() + newKCal)
					}
					else if quantityTypeIdentifier == .heartRate {
						let heartRate : Double = sample.quantity.doubleValue(for: HKUnit.init(from: "count/min"))
						strongSelf.setBPM(bpm: heartRate) //appends to heart rates too
					}
				}
				
				strongSelf.updateLabels()
			}
		}
	}
	
	func stopAccumulatingData() {
		for query in _activeDataQueries {
			_healthStore.stop(query)
		}
		
		_activeDataQueries.removeAll()
		stopTimer()
	}
	
	func pauseAccumulatingdata() {
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf._isPaused = true
		}
	}
	
	func resumeAccumulatingData() {
		DispatchQueue.main.async {
			[weak self] in
			guard let strongSelf = self else { return }
			strongSelf._isPaused = false
		}
	}
	
	// MARK : Timer Code
	
	func startTimer() {
		_timer = Timer.scheduledTimer(timeInterval: 1,
									  target: self,
									  selector: #selector(timerDidFire),
									  userInfo: nil,
									  repeats: true)
	}
	
	@objc func timerDidFire(_ timer : Timer) {
		updateLabels()
	}
	
	func stopTimer() {
		_timer?.invalidate()
	}
	
	// MARK : HKWorkoutSessionDelegate
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		print("Workout session did fail with error: \(error)")
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
		_workoutEvents.append(event)
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		switch toState
		{
			case .running:
				if fromState == .notStarted {
					startAccumulatingData(startDate: _workoutStartDate!)
				}
				else {
					resumeAccumulatingData()
				}
			case .paused:
				pauseAccumulatingdata()
			case .ended:
				stopAccumulatingData()
				saveWorkout()
			default:
				break
		}
		
		updateLabels()
		updateState()
	}
	
	private func saveWorkout() {
		//Create and save a workout sample
		let configuration = _workoutSession!.workoutConfiguration
		let isIndoor = (configuration.locationType == .indoor) as NSNumber
		print("locationType : \(configuration)")
		let duration = (_workoutEndDate ?? Date()).timeIntervalSince(_workoutStartDate!)
		let workout = HKWorkout(activityType: configuration.activityType,
								start: _workoutStartDate!,
								end: _workoutEndDate ?? Date(),
								duration: duration,
								totalEnergyBurned: _totalEnergyBurned,
								totalDistance: _totalDistance,
								metadata: [HKMetadataKeyIndoorWorkout : isIndoor])
		
		_healthStore.save(workout) { (success, _) in
			if success {
				print("Workout saved to health store")
				self.addSamples(toWorkout: workout)
			}
		}
		
		//send to iOS app
		_workoutHash[DataKeys.WorkoutID] = UUID.init().uuidString
		UserDefaults.standard.set(_workoutHash[DataKeys.WorkoutID], forKey: DataKeys.WorkoutID)
		_workoutHash[DataKeys.WorkoutType] = format(activityType: configuration.activityType)
		_workoutHash[DataKeys.Duration] = format(duration: duration)
		_workoutHash[DataKeys.StartDate] = _workoutStartDate!
		_workoutHash[DataKeys.EndDate] = _workoutEndDate ?? Date()
		_workoutHash[DataKeys.Energy] = format(energy: _totalEnergyBurned)
		_workoutHash[DataKeys.Distance] = format(distance: _totalDistance)
		_workoutHash[DataKeys.Location] = format(locationType: configuration.locationType)
		_workoutHash[DataKeys.AverageBPM] = format(heartRate: _avgBPM)
		_workoutHash[Keys.ToDelete] = false
		WatchWCSessionManager.shared.send(message: [Keys.Data : _workoutHash])
		
		DispatchQueue.main.async {
			// Pass the workout to Summary Interface Controller
			WKInterfaceController.reloadRootPageControllers(withNames: ["Summary"],
															contexts: [workout],
															orientation: .horizontal,
															pageIndex: 0)
		}
	}
	
	private func addSamples(toWorkout workout : HKWorkout) {
		//create energy and distance samples
		let totalEnergyBurnedSample = HKQuantitySample(type: HKQuantityType.activeEnergyBurned(),
													   quantity: _totalEnergyBurned,
													   start: _workoutStartDate!,
													   end: _workoutEndDate ?? Date())
		let totalDistanceSample = HKQuantitySample(type: HKQuantityType.distanceWalkingRunning(),
												   quantity: _totalDistance,
												   start: _workoutStartDate!,
												   end: _workoutEndDate ?? Date())
		let heartRateSample = HKQuantitySample(type: HKQuantityType.heartRate(),
											   quantity: _avgBPM,
											   start: _workoutStartDate!,
											   end: _workoutEndDate ?? Date())
		//Add samples to workout
		_healthStore.add([totalEnergyBurnedSample, totalDistanceSample, heartRateSample], to: workout) { (success, error) in
			if success {
				//samples have been added
				print("Samples added to workout")
			}
		}
	}
}





