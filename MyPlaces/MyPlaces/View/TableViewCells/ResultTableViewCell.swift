//
//  ResultTableViewCell.swift
//  MyPlaces
//
//  Created by Paul Bonneville on 4/1/21.
//

import UIKit
import MapKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapViewHeight: NSLayoutConstraint!
    @IBOutlet weak var expandedStackView: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    
    var addPlaceHandler: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addButton.layer.cornerRadius = 6
        addButton.layer.masksToBounds = true
    }
    
    @IBAction func addPlaceTapped(_ sender: Any) {
        addPlaceHandler?()
    }
}
