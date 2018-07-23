//
//  CoreDataManager.swift
//  SpeedierSloth
//
//  Created by Adam on 5/19/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagerDelegate : class
{
	func onCoreDataUpdate()
}

class CoreDataManager : NSObject
{
	public static let shared : CoreDataManager = CoreDataManager()
	
	private override init() {
		
	}
	
	// MARK : Properties
	
	public weak var delegate : CoreDataManagerDelegate?
	
	// MARK : Core Data stack
	
	public lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "SpeedierSloth")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	//save dictionary
	func save(workoutHash : [String : Any]) {
		
		let managedContext = self.persistentContainer.viewContext
		
		let entity = NSEntityDescription.entity(forEntityName: "CoreWorkout", in: managedContext)!
		let coreWorkout = NSManagedObject(entity: entity, insertInto: managedContext)
		let workout : Workout = Workout(hash: workoutHash)
		workout.populateManagedObject(managedObject: coreWorkout)
		
		do {
			try managedContext.save()
			delegate?.onCoreDataUpdate()
			print("Saved to core data")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	func delete(workoutID : String) {
		
		let managedContext = self.persistentContainer.viewContext
		
		let fetchRequest: NSFetchRequest<CoreWorkout> = CoreWorkout.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "workoutID = %@", workoutID)
		let workouts = try! managedContext.fetch(fetchRequest)
		guard let first = workouts.first else {
			return
		}
		managedContext.delete(first)
		
		do {
			try managedContext.save()
			delegate?.onCoreDataUpdate()
			print("Deleted from core data")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
}
