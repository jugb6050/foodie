//
//  ViewController.swift
//  foodie
//
//  Created by Thenura Jayasinghe on 2021-03-25.
//

import UIKit
import MapKit
import CoreLocation
import FittedSheets
import Foundation

//protocol HomeControllerDelegate {
//    func didSentMessage(_ message: [[String]])
//}

class HomeController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
//    var homeControllerDelegate: HomeControllerDelegate?
        
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var activityLoader: UIActivityIndicatorView!
    let locationManager = CLLocationManager()

    // Holds all restaurants (master array)
    public var restaurants = [Restaurant]()
    
    // Temp variables to help dynamic map rendering
    public var allPoints = [MKPointAnnotation]()
    public var restaurantsInRange = [Restaurant]()

    private var mapChangedFromUserInteraction = false
    
    
    // MARK: HomeController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start and Display Loading Spinner
        showActivityIndicator()
        
        // API Call to Fetch All Restaurants
        getRestaurants()
        
        // Create Map View
        setupMapView()
        
        // Get All Restaurants In Radius
        getAnnotationsInCurrentRadius()

        // Check Permissions
        checkLocationServices()
        
        mapView.delegate = self
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Change `2.0` to the desired number of seconds.
           // Code you want to be delayed
            self.sendNotificationToObservers()
        }
        
        
    // add pan gesture to detect when the map moves
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))

        // make your class the delegate of the pan gesture
        panGesture.delegate = self

        // add the gesture to the mapView
        mapView.addGestureRecognizer(panGesture)
        
        //print(self.mapView.currentRadius())
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // On Map Drag Complete
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            print("MAP DRAG COMPLETE")
            getAnnotationsInCurrentRadius()
            sendNotificationToObservers()

        }
    }
    
    // Send notification to Observers (NotificationCenter)
    private func sendNotificationToObservers() {
        // Create Temporary Dictionary to Store All Restaurants In Range
        let someDict:[String:[Restaurant]] = ["data": restaurantsInRange]
        
        // Push Notification to All Observers
        NotificationCenter.default.post(name: Notification.Name("didReceiveData"), object: nil, userInfo: someDict)
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( (recognizer.state == UIGestureRecognizer.State.began) || (recognizer.state == UIGestureRecognizer.State.ended) ) {
                    return true
                }
            }
        }
        return false
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()

    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            
            print("ZOOM Finished")
            getAnnotationsInCurrentRadius()
            
            sendNotificationToObservers()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: Setup Helper Function
    
    func setupSearchCard(){
        SearchResultsController.setupCard(from: self, in: self.view)
    }
    
    // MARK: Activity Indicator

    func showActivityIndicator() {
        activityLoader = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityLoader.hidesWhenStopped = true
        activityLoader.center = CGPoint(x: self.view.center.x, y: self.view.center.y  - 75)
        self.view.isUserInteractionEnabled = false
        
        self.mapView.addSubview(activityLoader)
        activityLoader.startAnimating()
    }
    
    func stopActivityIndicator() {
        // Stop animation and reset user interaction (can touch screen)
        self.activityLoader.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    // MARK: Segue Functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSegue(withIdentifier: "searchTableVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Pass restaurant data to another view controller
        if segue.destination is SearchTableViewController {
            let vc = segue.destination as? SearchTableViewController
            vc?.restaurants = self.restaurants
        }
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
    }
    
    // MARK: Location Services
    
    // Adhere to CLLocationManagerDelegate protocol
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 4000, longitudinalMeters: 4000)
        mapView.setRegion(region, animated: true)
    }
    
    // Verify various authorization cases based
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus{
        case .authorizedAlways:
            break
        // Share only when using the application - no background
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            followUserLocation()
            locationManager.startUpdatingLocation()
            break
        // Poor GPS signal
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        // User doesn't want to share location
        case .denied:
            // Show alert
            break
        case .restricted:
            // Show alert
            break
        @unknown default:
            // Show error
            break
        }
    }
    
    func checkLocationServices() {
        // Check if location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // the user didn't turn it on
            // provide an alert
        }
    }
    
    // Updates map based on user location
    func followUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 4000, longitudinalMeters: 4000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // If user change settings, present location auth
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    // MARK: MapKit Helper Functions
    
    func addAnnotations() {
        // Iterate through all restaurants and add them to mapview
        for restaurant in self.restaurants{
            // Incoming long lat -> Switch to lat, long
            
            let coords: GeoCoordinates = GeoCoordinates(coordinates: [restaurant.location.geo.coordinates[0], restaurant.location.geo.coordinates[1]])
            
            let point = MKPointAnnotation()
            
            point.title = restaurant.name
            point.subtitle = restaurant.location.address
            point.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(coords[1]), longitude: CLLocationDegrees(coords[0]))
            
            mapView.addAnnotation(point)
            allPoints.append(point)

        }
    }
    
    public func getAnnotationsInCurrentRadius() { // -> [[String]]
        let updatedRadius = mapView.currentRadius() // this gives the max radius of the current map region from the current user center point
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude) // var for current user center location
        restaurantsInRange.removeAll() // clears restaurants that are within the range
        for point in allPoints{ // loops through all point annotations
            let pointLocation = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude) // var for the location of the point
            if((centerLocation.distance(from: pointLocation)) <= (updatedRadius - 600)){ // checks if the point distance from the center of the map view is <= to the radius
                    //annotationsInCurrentRadius.append(point) // if it is within the radius it adds it to the array that tracks annotations within the current radius which will be used to display data on pull up menu
                for restaurant in self.restaurants{ // for all restaurants in the restaurant array, if the point title matches the restaurant name, then the restaurant is added to the restaurants in range array
                    if(point.title == restaurant.name){
                        restaurantsInRange.append(restaurant) 
                    }
                }
            }
                
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    // MARK: API Helper Functions
    
    func getRestaurants() {
        let url = URL(string: "https://onlyfoodsapi.herokuapp.com/restaurants")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response , error) in
            
            guard let data = data, error == nil else {
                print("Error")
                return
            }
            
            var result: [Restaurant]
            do {
                result = try JSONDecoder().decode([Restaurant].self, from: data)
                
                DispatchQueue.main.async {
                    self.restaurants = result
                    self.addAnnotations()
                    self.stopActivityIndicator()
                    self.setupSearchCard()
                    
                }
            } catch {
                print("Failed to convert")
            }
            
        })
        task.resume()
    }
}


private extension MKMapView {
    //    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    //        let coordinateRegion = MKCoordinateRegion(
    //            center: location.coordinate,
    //            latitudinalMeters: regionRadius,
    //            longitudinalMeters: regionRadius)
    //        setRegion(coordinateRegion, animated: true)
    //    }
    
    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
    func currentRadius() -> Double {
        let centerLocation = CLLocation(latitude: self.centerCoordinate.latitude, longitude: self.centerCoordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }
    
}

//func disableMapView () {
//    mapView.isZoomEnabled = false
//    mapView.isScrollEnabled = false
//    mapView.isUserInteractionEnabled = false
//}
