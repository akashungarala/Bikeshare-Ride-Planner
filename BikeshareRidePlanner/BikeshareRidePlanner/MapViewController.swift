//
//  MapViewController.swift
//  BikeshareRidePlanner
//
//  Created by Akash Ungarala on 9/19/17.
//  Copyright © 2017 Akash Ungarala. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var originSearchBar: UISearchBar!
    @IBOutlet weak var destinationSearchBar: UISearchBar!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    // Handles action for the search button
    @IBAction func searchTapped(_ sender: UIButton) {
        view.endEditing(true)
        beginIgnore()
        if !(originSearchBar.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty)! {
            if (originLocationCoordinates != nil) {
                if (self.destinationLocationCoordinates != nil) {
                    self.checkOriginDestination()
                } else {
                    self.searchDestination()
                }
            } else {
                searchOrigin()
            }
        } else {
            stopIgnore()
            self.alert("Origin can not be empty")
        }
    }
    
    // Set Current Location as the Origin
    @IBAction func selectCurrentLocation(_ sender: UIButton) {
        view.endEditing(true)
        originSearchBar.text = currentLocationAddress
        originLocationCoordinates = currentLocationCoordinates
    }
    
    // Swap Origin and Destination
    @IBAction func reverseOriginDestination(_ sender: UIButton) {
        view.endEditing(true)
        if let originString = originSearchBar.text {
            if let destinationString = destinationSearchBar.text {
                originSearchBar.text = destinationString
            }
            destinationSearchBar.text = originString
        } else if let destinationString = destinationSearchBar.text {
            originSearchBar.text = destinationString
        }
        if (originLocationCoordinates != nil) {
            let originCoordinates = originLocationCoordinates
            if (destinationLocationCoordinates != nil) {
                let destinationCoordinates = destinationLocationCoordinates
                originLocationCoordinates = destinationCoordinates
            }
            destinationLocationCoordinates = originCoordinates
        } else if (destinationLocationCoordinates != nil) {
            let destinationCoordinates = destinationLocationCoordinates
            originLocationCoordinates = destinationCoordinates
        }
    }
    
    // Zoom to the region of Current Location
    @IBAction func goToMyLocation(_ sender: UIButton) {
        view.endEditing(true)
        if currentLocationCoordinates != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocationCoordinates, 2400, 2400)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // Handles action for distance slider
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        view.endEditing(true)
        distanceLabel.text = String(format:"%.2f", sender.value)+" Miles"
    }
    
    let locationManager = CLLocationManager()
    let activityIndicator = UIActivityIndicatorView()
    
    var searchActive = false
    var isOriginSearchBar = false
    
    var originSearchResults = [CLPlacemark]()
    var destinationSearchResults = [CLPlacemark]()
    
    var currentLocationAddress = "Current Location"
    var currentLocationCoordinates: CLLocationCoordinate2D!
    var originLocationCoordinates: CLLocationCoordinate2D!
    var destinationLocationCoordinates: CLLocationCoordinate2D!
    var bikeshareStationAnnotations = [BikeshareStationAnnotation]()
    var selectedBikeshareStationAnnotation: BikeshareStationAnnotation!
    var originAnnotation: MKPointAnnotation!
    var destinationAnnotation: MKPointAnnotation!
    var searchResultController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up the UI
        setGestureRecognizersToDismissKeyboard()
        if let textFieldInsideSearchBar = originSearchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = Utility.color.grey
            textFieldInsideSearchBar.font = UIFont(name: "HelveticaNeue-CondensedBold ", size: 16)
            if let textFieldInsideSearchBarLabel = textFieldInsideSearchBar.value(forKey: "placeholderLabel") as? UILabel {
                textFieldInsideSearchBarLabel.textColor = Utility.color.grey
                textFieldInsideSearchBarLabel.font = UIFont(name: "HelveticaNeue-CondensedBold ", size: 16)
                if let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as? UIButton {
                    clearButton.addTarget(self, action: #selector(originClearButtonTapped), for: .touchUpInside)
                    clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                    clearButton.tintColor = Utility.color.grey
                }
            }
            if let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = Utility.color.grey
            }
        }
        if let textFieldInsideSearchBar = destinationSearchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = Utility.color.grey
            textFieldInsideSearchBar.font = UIFont(name: "HelveticaNeue-CondensedBold ", size: 16)
            if let textFieldInsideSearchBarLabel = textFieldInsideSearchBar.value(forKey: "placeholderLabel") as? UILabel {
                textFieldInsideSearchBarLabel.textColor = Utility.color.grey
                textFieldInsideSearchBarLabel.font = UIFont(name: "HelveticaNeue-CondensedBold ", size: 16)
                if let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as? UIButton {
                    clearButton.tintColor = Utility.color.grey
                    clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                    clearButton.addTarget(self, action: #selector(destinationClearButtonTapped), for: .touchUpInside)
                }
            }
            if let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
                glassIconView.tintColor = Utility.color.grey
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            }
        }
        distanceSlider.setThumbImage(UIImage(named: "slider"), for: .normal)
        distanceSlider.setThumbImage(UIImage(named: "slider"), for: .focused)
        distanceSlider.setThumbImage(UIImage(named: "slider"), for: .highlighted)
        distanceSlider.setThumbImage(UIImage(named: "slider"), for: .selected)
        searchResultsTableView.isHidden = true
        // Setting up the User Location
        locationManager.delegate = self
        let authorizationCode = CLLocationManager.authorizationStatus()
        if (authorizationCode == CLAuthorizationStatus.notDetermined && locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil {
                locationManager.requestWhenInUseAuthorization()
            } else {
                print("No Description Provided")
            }
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not enabled")
        }
        // Setting up the Activity Indicator
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        // Setting uo the Map
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
        mapView.showsScale = false
        mapView.showsCompass = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        beginIgnore()
        // Fetch Bikeshare Station Annotations from the url
        AuthService.sharedInstance.fetchBikeshareStations { (bikeshareStationAnnotations) in
            if bikeshareStationAnnotations != nil {
                self.bikeshareStationAnnotations = bikeshareStationAnnotations!
                self.mapView.addAnnotations(bikeshareStationAnnotations!)
                self.stopIgnore()
            } else {
                self.stopIgnore()
                self.alert("There are no Bikeshare Stations")
            }
        }
    }
    
    // Begin ignoring user interaction
    func beginIgnore() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
    }
    
    // Stop ignoring user interaction
    func stopIgnore() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // Handles presenting alert to the user with given message and title
    func alert(_ message: String, title: String = "") {
        // Create an alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create an alert action
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        // Add the alert action to the alert controller
        alertController.addAction(OKAction)
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Setting up the gesture recognizers to dismiss the keyboard
    func setGestureRecognizersToDismissKeyboard() {
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        searchView.addGestureRecognizer(tapGesture)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        view.endEditing(true)
    }
    
}

extension CLPlacemark {
    
    // To fetch the address parsed from the placemark
    func parseAddress() -> String {
        let firstSpace = (self.subThoroughfare != nil && self.thoroughfare != nil) ? " " : ""
        let comma = (self.subThoroughfare != nil || self.thoroughfare != nil) && (self.subAdministrativeArea != nil || self.administrativeArea != nil) ? ", " : ""
        let secondSpace = (self.subAdministrativeArea != nil && self.administrativeArea != nil) ? " " : ""
        let addressLine = String(format:"%@%@%@%@%@%@%@", self.subThoroughfare ?? "", firstSpace, self.thoroughfare ?? "", comma, self.locality ?? "", secondSpace, self.administrativeArea ?? "")
        return addressLine
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isOriginSearchBar = (searchBar.tag == 100)
        searchActive = true
        if isOriginSearchBar {
            if (originSearchBar.text != nil && !(originSearchBar.text?.isEmpty)!) {
                searchResultsTableView.isHidden = false
            } else {
                self.originLocationCoordinates = nil
                self.originSearchResults.removeAll()
                searchResultsTableView.isHidden = true
            }
        } else {
            if (destinationSearchBar.text != nil && !(destinationSearchBar.text?.isEmpty)!) {
                searchResultsTableView.isHidden = false
            } else {
                self.destinationLocationCoordinates = nil
                self.destinationSearchResults.removeAll()
                searchResultsTableView.isHidden = true
            }
        }
        searchResultsTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false
        searchResultsTableView.isHidden = true
    }
    
    func originClearButtonTapped() {
        originLocationCoordinates = nil
        originSearchResults.removeAll()
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = true
    }
    
    func destinationClearButtonTapped() {
        destinationLocationCoordinates = nil
        destinationSearchResults.removeAll()
        searchResultsTableView.reloadData()
        searchResultsTableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false
        searchResultsTableView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isOriginSearchBar {
            originLocationCoordinates = nil
            originSearchResults.removeAll()
            if (originSearchBar.text != nil && !(originSearchBar.text?.isEmpty)!) {
                searchLocation(originSearchBar.text!, completion: { response in
                    if response != nil {
                        for mapItem in (response?.mapItems)! {
                            self.originSearchResults.append(mapItem.placemark)
                        }
                        self.searchResultsTableView.isHidden = (self.originSearchResults.count == 0)
                        self.searchResultsTableView.reloadData()
                    } else {
                        self.searchResultsTableView.isHidden = true
                        self.searchResultsTableView.reloadData()
                    }
                })
            } else {
                searchResultsTableView.isHidden = true
                searchResultsTableView.reloadData()
            }
        } else {
            destinationLocationCoordinates = nil
            destinationSearchResults.removeAll()
            if (destinationSearchBar.text != nil && !(destinationSearchBar.text?.isEmpty)!) {
                searchLocation(destinationSearchBar.text!, completion: { response in
                    if response != nil {
                        for mapItem in (response?.mapItems)! {
                            self.destinationSearchResults.append(mapItem.placemark)
                        }
                        self.searchResultsTableView.isHidden = (self.destinationSearchResults.count == 0)
                        self.searchResultsTableView.reloadData()
                    } else {
                        self.searchResultsTableView.isHidden = true
                        self.searchResultsTableView.reloadData()
                    }
                })
            } else {
                searchResultsTableView.isHidden = true
                searchResultsTableView.reloadData()
            }
        }
    }
    
}

extension MapViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ((isOriginSearchBar) ? originSearchResults.count : destinationSearchResults.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = ((isOriginSearchBar) ? originSearchResults[indexPath.row] : destinationSearchResults[indexPath.row])
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.type = isOriginSearchBar
        cell.placemark = searchResult
        return cell
    }
    
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPlacemark = ((isOriginSearchBar) ? originSearchResults[indexPath.row] : destinationSearchResults[indexPath.row])
        if isOriginSearchBar {
            originSearchBar.text = selectedPlacemark.parseAddress()
            originLocationCoordinates = selectedPlacemark.location?.coordinate
        } else {
            destinationSearchBar.text = selectedPlacemark.parseAddress()
            destinationLocationCoordinates = selectedPlacemark.location?.coordinate
        }
        view.endEditing(true)
        searchActive = false;
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations.last!
        currentLocationCoordinates = location.coordinate
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocationCoordinates, 2400, 2400)
        self.mapView.setRegion(coordinateRegion, animated: true)
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil && placemarks != nil && (placemarks?.count)! > 0 {
                let placemark = (placemarks?[0])!
                self.currentLocationAddress = placemark.parseAddress()
            } else {
                self.alert("")
            }
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = MKAnnotationView()
        var imageName = ""
        if annotation is BikeshareStationAnnotation {
            let bikeshareStationAnnotation = annotation as! BikeshareStationAnnotation
            let directionsTitle = bikeshareStationAnnotation.getDirectionsTitle()
            imageName = bikeshareStationAnnotation.getImageName()
            let directionsLink = UIButton(type: .custom)
            directionsLink.setTitle(directionsTitle, for: .normal)
            directionsLink.setTitleColor(Utility.color.red, for: .normal)
            directionsLink.addTarget(self, action: #selector(directionsToTapped), for: .touchUpInside)
            annotationView.detailCalloutAccessoryView = directionsLink
        } else if annotation.title! == "Origin" {
            imageName = Utility.image.origin
        } else if annotation.title! == "Destination" {
            imageName = Utility.image.destination
        }
        let annotationImageView = Utility.image.getImageView(imageName, width: 40, height: 40)
        annotationView.frame = annotationImageView.frame
        annotationView.addSubview(annotationImageView)
        annotationView.canShowCallout = true
        annotationView.contentMode = UIViewContentMode.scaleAspectFit
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedBikeshareStationAnnotation = nil
        if view.annotation is BikeshareStationAnnotation {
            selectedBikeshareStationAnnotation = view.annotation as! BikeshareStationAnnotation
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((view.annotation?.coordinate)!, 2400, 2400)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func directionsToTapped() {
        if selectedBikeshareStationAnnotation != nil {
            if (originAnnotation != nil && destinationAnnotation != nil) {
                if selectedBikeshareStationAnnotation.rangeStatus == .origin {
                    // origin to selected
                    selectedBikeshareStationAnnotation.openInMaps(from: originAnnotation)
                } else if selectedBikeshareStationAnnotation.rangeStatus == .destination {
                    // selected to destination
                    selectedBikeshareStationAnnotation.openInMaps(to: destinationAnnotation)
                }
            } else {
                // current to selected
                selectedBikeshareStationAnnotation.openInMaps()
            }
        }
    }
    
    func getDirections(_ originLocationCoordinates: CLLocationCoordinate2D, _ destinationLocationCoordinates: CLLocationCoordinate2D, completion: @escaping (MKDirectionsResponse?) -> ()) {
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: originLocationCoordinates))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocationCoordinates))
        directionRequest.transportType = .walking
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if error == nil && response != nil {
                completion(response)
            } else {
                completion(nil)
            }
        }
    }
    
    func searchLocation(_ string: String, completion: @escaping (MKLocalSearchResponse?) -> ()) {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = string
        let search = MKLocalSearch(request: searchRequest)
        search.start(completionHandler: { (response, error) in
            if error == nil && response != nil {
                completion(response)
            } else {
                completion(nil)
            }
        })
    }
    
    func searchOrigin() {
        let originString = originSearchBar.text!
        searchLocation(originString, completion: { response in
            if let originResponse = response {
                self.originLocationCoordinates = CLLocationCoordinate2DMake((originResponse.boundingRegion.center.latitude), (originResponse.boundingRegion.center.longitude))
                if !(self.destinationSearchBar.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty)! {
                    let destinationString = self.destinationSearchBar.text!
                    if destinationString != originString {
                        if (self.destinationLocationCoordinates != nil) {
                            self.checkOriginDestination()
                        } else {
                            self.searchDestination()
                        }
                    } else {
                        self.originLocationCoordinates = nil
                        self.stopIgnore()
                        self.alert("Origin and Destination can not be the same location")
                    }
                } else {
                    self.originLocationCoordinates = nil
                    self.stopIgnore()
                    self.alert("Destination can not be empty")
                }
            } else {
                self.stopIgnore()
                self.alert("Failed to search Origin")
            }
        })
    }
    
    func searchDestination() {
        let destinationString = destinationSearchBar.text!
        searchLocation(destinationString, completion: { response in
            if let destinationResponse = response {
                self.destinationLocationCoordinates = CLLocationCoordinate2DMake((destinationResponse.boundingRegion.center.latitude), (destinationResponse.boundingRegion.center.longitude))
                self.checkOriginDestination()
            } else {
                self.stopIgnore()
                self.alert("Failed to search Destination")
            }
        })
    }
    
    func checkOriginDestination() {
        if !(originLocationCoordinates.latitude == destinationLocationCoordinates.latitude && originLocationCoordinates.longitude == destinationLocationCoordinates.longitude) {
            searchSuccess()
        } else {
            self.originLocationCoordinates = nil
            self.destinationLocationCoordinates = nil
            stopIgnore()
            alert("Origin and Destination can not be the same location")
        }
    }
    
    func searchSuccess() {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.originAnnotation = MKPointAnnotation()
        self.destinationAnnotation = MKPointAnnotation()
        self.originAnnotation.title = "Origin"
        self.originAnnotation.coordinate = originLocationCoordinates
        self.destinationAnnotation.title = "Destination"
        self.destinationAnnotation.coordinate = destinationLocationCoordinates
        for annotation in self.bikeshareStationAnnotations {
            annotation.updateRangeStatus(originAnnotation: originAnnotation, destinationAnnotation: destinationAnnotation, distance: distanceSlider.value)
            if (annotation.rangeStatus == .origin || annotation.rangeStatus == .destination) {
                self.mapView.addAnnotation(annotation)
            }
        }
        self.mapView.addAnnotations([self.originAnnotation, self.destinationAnnotation])
        getDirections(originLocationCoordinates, destinationLocationCoordinates) { directionsResponse in
            if let response = directionsResponse {
                let route = response.routes[0]
                self.mapView.add(route.polyline, level: .aboveRoads)
                self.mapView.setRegion(MKCoordinateRegionForMapRect(route.polyline.boundingMapRect), animated: true)
                self.stopIgnore()
            } else {
                let originCoordinateRegion = MKCoordinateRegionMakeWithDistance(self.originLocationCoordinates, 2400, 2400)
                self.mapView.setRegion(originCoordinateRegion, animated: true)
                self.stopIgnore()
                self.alert("Unable to fetch walking directions from the origin to the destination")
            }
        }
    }
    
}
