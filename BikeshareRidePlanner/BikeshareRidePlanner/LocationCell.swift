//
//  LocationCell.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/24/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var type: Bool! {
        didSet {
            if type {
                locationImage.image = UIImage(named: "origin")
            } else {
                locationImage.image = UIImage(named: "destination")
            }
        }
    }
    var placemark: CLPlacemark! {
        didSet {
            name.text = placemark.name
            address.text = placemark.parseAddress()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
