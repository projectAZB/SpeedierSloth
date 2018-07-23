//
//  ListViewController.swift
//  SpeedierSloth
//
//  Created by Adam on 5/16/18.
//  Copyright © 2018 Adam. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: BaseViewController, NSFetchedResultsControllerDelegate
{
	// MARK : IB Outlets
	
	@IBOutlet weak var _tableView: UITableView!
	
	// MARK : Properties
	
	let _search = UISearchController(searchResultsController: nil)
	
	var _currentPredicate: NSPredicate = NSPredicate(format: "workoutType CONTAINS[cd] %@", NSString(string: "running"))
	
	let _scopes : [String] = ["Running", "Walking", "Hiking"]
	
	var _selectedScope : String {
		get {
			return _scopes[_search.searchBar.selectedScopeButtonIndex].lowercased()
		}
	}
	
	var _searchText : String {
		get {
			return _search.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
		}
	}
	
	lazy var fetchedResultsController: NSFetchedResultsController<CoreWorkout> = {
		let fetchRequest = NSFetchRequest<CoreWorkout>(entityName: "CoreWorkout")
		fetchRequest.fetchBatchSize = 50
		fetchRequest.predicate = self._currentPredicate
		let dateDescriptor = NSSortDescriptor(key: DataKeys.StartDate, ascending: false)
		fetchRequest.sortDescriptors = [dateDescriptor]
		
		let _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																   managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext,
																   sectionNameKeyPath: DataKeys.Month,
																   cacheName: nil)
		_fetchedResultsController.delegate = self
		return _fetchedResultsController
		
	}()
	
	// MARK : View Controller
	
    override func viewDidLoad() {
        super.viewDidLoad()

		_search.searchResultsUpdater = self
		_search.delegate = self
		_search.searchBar.tintColor = UIColor.white
		_search.searchBar.isTranslucent = false
		// Show a scope bar for additional filtering parameters
		_search.searchBar.placeholder = "Search locations (i.e. outdoor, indoor)"
		_search.searchBar.delegate = self
		_search.searchBar.scopeButtonTitles = _scopes
		self.navigationItem.searchController = _search
		definesPresentationContext = true
		
		_tableView.delegate = self
		_tableView.dataSource = self
		_tableView.tableFooterView = UIView(frame: .zero)
		_tableView.separatorInset = UIEdgeInsets.zero
		_tableView.rowHeight = WorkoutCell.Height
		
		NotificationCenter.default.addObserver(self,
											   selector: #selector(updateTableView),
											   name: .coreDataUpdate,
											   object: nil)
		
		fetch()
    }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func updateTableView() {
		fetch()
		self._tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let nav = self.navigationController {
			nav.navigationItem.hidesSearchBarWhenScrolling = false
		}
	}

}

extension ListViewController : UITableViewDataSource, UITableViewDelegate, WorkoutCellDelegate
{
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections.count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController.sections {
			let currentSection = sections[section]
			return currentSection.numberOfObjects
		}
		return 0
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let sections = fetchedResultsController.sections {
			let currentSection = sections[section]
			return "  \(currentSection.name)"
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutCell.Identifier, for: indexPath) as! WorkoutCell
		cell.delegate = self
		
		let workoutManagedObject : NSManagedObject = fetchedResultsController.object(at: indexPath)
		let workout : Workout = Workout(managedObject: workoutManagedObject)
		cell.configure(workout: workout)
		
		return cell
	}
	
	// MARK : WorkoutCellDelegate
	
	func onWorkoutSelected(workout: Workout) {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		guard let detailVC : DetailViewController = storyboard.instantiateViewController(withIdentifier: "detail") as? DetailViewController else {
			return
		}
		detailVC._workout = workout
		if let nav = self.navigationController {
			nav.pushViewController(detailVC, animated: true)
		}
	}
}

extension ListViewController : UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate
{
	
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		filterResultsForSearchText()
	}
	
	func fetch() {
		do {
			fetchedResultsController.fetchRequest.predicate = _currentPredicate
			try self.fetchedResultsController.performFetch()
		} catch {
			let nserror = error as NSError
			print("Unresolved error \(nserror), \(nserror.userInfo)")
		}
	}
	
	func filterResultsForSearchText() {
		if _searchText.count == 0 {
			_currentPredicate = NSPredicate(format: "workoutType CONTAINS[cd] %@", _selectedScope)
		} else {
			_currentPredicate = NSPredicate(format: "workoutType CONTAINS[cd] %@ AND location CONTAINS[cd] %@", _selectedScope, _searchText)
		}
		updateTableView()
	}
	
	// MARK : UISearchControllerDelegate
	
	func willPresentSearchController(_ searchController: UISearchController) {
		
	}
	
	func didPresentSearchController(_ searchController: UISearchController) {
		
	}
	
	// MARK : UISearchResultsUpdating
	
	func updateSearchResults(for searchController: UISearchController) {
		filterResultsForSearchText()
	}
}
