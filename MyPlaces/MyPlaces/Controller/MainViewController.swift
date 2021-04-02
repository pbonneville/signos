//
//  ViewController.swift
//  MyPlaces
//
//  Created by Paul Bonneville on 3/31/21.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Variables
    
    private var appDelegate: AppDelegate?
    private var context: NSManagedObjectContext?
    
    @IBOutlet var getStartedView: UIView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<PlaceMO> = {
        let fetchRequest: NSFetchRequest<PlaceMO> = PlaceMO.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context!,
            sectionNameKeyPath: nil,
            cacheName: nil)

        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultsController = storyboard.instantiateViewController(withIdentifier: "searchResults") as! UITableViewController
        let searchController = UISearchController(searchResultsController: resultsController )
        searchController.searchResultsUpdater = resultsController as? UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Start typing to begin search..."
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.scopeButtonTitles = PlaceAPIService.placeTypes()
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        loadSavedData()
    }
    
    // MARK: - Tableview methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        
        configureCell(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func configureCell(_ cell: PlaceTableViewCell, at indexPath: IndexPath) {
        let place = fetchedResultsController.object(at: indexPath) as PlaceMO
        
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.address
        cell.placeTypeLabel.text = place.type
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let diaryEntry = fetchedResultsController.object(at: indexPath)
            fetchedResultsController.managedObjectContext.delete(diaryEntry)
            appDelegate?.saveContext()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - IBActions
    
    @IBAction func editTapped(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    @IBAction func addTapped(_ sender: Any) {
        if let context = context {
            let placeEntry = PlaceMO.init(context: context)
            placeEntry.name = "test"
            
            if let appDelegate = appDelegate {
                appDelegate.saveContext()
            }
        }
    }
    
    // MARK: - Fetch results controller methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateTableViewBackground()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell as! PlaceTableViewCell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        @unknown default:
            fatalError()
        }
    }
    
    // MARK: - Private methods
    
    private func updateTableViewBackground() {
        var placeCount = 0
        
        do {
            placeCount = try context?.count(for:PlaceMO.fetchRequest()) ?? 0
        } catch {
            print(error.localizedDescription)
        }
        
        tableView.backgroundView = placeCount == 0 ? getStartedView : nil
    }
    
    private func loadSavedData() {
        updateTableViewBackground()
                
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
}

// MARK: - Extensions

extension MainViewController: UISearchBarDelegate {
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("click")
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print("selected scope: \(selectedScope)")
    }
    
}

