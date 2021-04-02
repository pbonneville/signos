//
//  SearchResultsTableViewController.swift
//  MyPlaces
//
//  Created by Paul Bonneville on 4/1/21.
//

import UIKit
import CoreData
import MapKit

class SearchResultsTableViewController: UITableViewController {

    // MARK: - Variables
    
    private var appDelegate: AppDelegate?
    private var context: NSManagedObjectContext?
    
    @IBOutlet weak var loadingView: LoadingResultsView!
    
    let placeAPIService = PlaceAPIService()
    var delayTimer = Timer()
    var places = [Result]()
    var expandedCells : IndexSet = []
    var scopeIndex = 0
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        
        tableView.backgroundView = loadingView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    // MARK: - Table view data source & delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultTableViewCell
        let place = places[indexPath.row]
        let placeType = PlaceAPIService.PlaceType(rawValue: self.scopeIndex)?.description().capitalized
                
        if let lat = place.geometry?.location?.lat, let lng = place.geometry?.location?.lng {
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            cell.mapView.setRegion(MKCoordinateRegion(center: center, latitudinalMeters: 200, longitudinalMeters: 200), animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            cell.mapView.addAnnotation(annotation)
        }
        
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.formattedAddress
        cell.placeTypeLabel.text = placeType
        cell.expandedStackView.isHidden = !expandedCells.contains(indexPath.row)
        cell.addPlaceHandler = {
            if let context = self.context {
                let placeToAdd = PlaceMO(context: context)
                placeToAdd.name = place.name
                placeToAdd.address = place.formattedAddress
                placeToAdd.type = placeType
                
                self.appDelegate?.saveContext()
            }
            self.presentingViewController?.navigationItem.searchController?.searchBar.searchTextField.text = ""

            self.dismiss(animated: true, completion: nil)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ResultTableViewCell else {
            return
        }

        if expandedCells.contains(indexPath.row) {
            expandedCells.remove(indexPath.row)
        } else {
            expandedCells.insert(indexPath.row)
        }
        
        let isHidden = !expandedCells.contains(indexPath.row)
        cell.mapViewHeight.isActive = !isHidden
        cell.layoutIfNeeded()
        
        cell.expandedStackView.isHidden = isHidden
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Extensions

extension SearchResultsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        scopeIndex = searchController.searchBar.selectedScopeButtonIndex
        
        guard let placeType = PlaceAPIService.PlaceType.init(rawValue: scopeIndex) else {
            return
        }
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
        
        places.removeAll()
        tableView.reloadData()
        
        delayTimer.invalidate()
        delayTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            if let searchText = searchController.searchBar.text, searchText.count > 1 {
                self.placeAPIService.search(searchText: searchText, placeType: placeType) { placeResults in
                    if let results = placeResults?.results {
                        self.places = results
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()                            
                        }
                    }
                }
            }
        }
    }
}
