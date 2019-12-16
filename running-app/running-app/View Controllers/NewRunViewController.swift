import UIKit
import CoreLocation
import MapKit

class NewRunViewController: UIViewController {
  
  @IBOutlet weak var launchPromptStackView: UIStackView!
  @IBOutlet weak var dataStackView: UIStackView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  
  @IBOutlet weak var mapContainerView: UIView!
  @IBOutlet weak var mapView: MKMapView!
  
  private var run: Run?
  
  //Objekt um LocationService zu starten bzw. zu stoppen
  private let locationManager = LocationManager.shared
  
  //Trackt die länge des Run in Sekunden
  private var seconds = 0
  
  //Fired jede Sekunde und updated das UI
  private var timer: Timer?
  
  //Speichert die zurückgelegte Distanz
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
  
  //Hälte alle während dem Run zurückgelegten CLLocation-Objekte
  private var locationList: [CLLocation] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataStackView.isHidden = true
    startButton.layer.cornerRadius = 20
    stopButton.layer.cornerRadius = 20
    tabBarController?.tabBar.items![0].title = "Home Screen"
    tabBarController?.tabBar.items![1].title = "Neuer Run"
    tabBarController?.tabBar.items![2].title = "Dashboard"
    tabBarController?.tabBar.items![0].image = #imageLiteral(resourceName: "home25.png")
    tabBarController?.tabBar.items![1].image = #imageLiteral(resourceName: "running25.png")
    tabBarController?.tabBar.items![2].image = #imageLiteral(resourceName: "dashboard25.png")
  }
  
  /*Dadurch wird sichergestellt, dass Standortaktualisierungen sowie der Timer gestoppt werden, wenn der Benutzer aus der
   Ansicht heraus navigiert.*/
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer?.invalidate()
    locationManager.stopUpdatingLocation()
      navigationController?.setNavigationBarHidden(false, animated: animated)
  }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
}
  
  //wird jede Sekunde vom Timer gecalled
  func eachSecond() {
    seconds += 1
    updateDisplay()
  }

  //Updated das UI und zwar jede Sekunde -> greift auf die FormatDisplay Klasse zu
  private func updateDisplay() {
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.kilometersPerHour)
     let index = formattedDistance.index(formattedDistance.startIndex, offsetBy: 5)
     let mySubstring = formattedDistance.prefix(upTo: index)
    distanceLabel.text = "Distance:  \(mySubstring) \("Meter")"
    timeLabel.text = "Zeit:  \(formattedTime)"
    paceLabel.text = "Geschwindigkeit:  \(formattedPace)"
  }
  
  private func startRun() {
    mapContainerView.isHidden = false
    mapView.removeOverlays(mapView.overlays)
    launchPromptStackView.isHidden = true
    dataStackView.isHidden = false
    startButton.isHidden = true
    stopButton.isHidden = false
    
    /*Dadurch werden alle während des Laufs zu aktualisierenden Werte in ihren Ausgangszustand zurückgesetzt,
     der Timer gestartet, der jede Sekunde ausgelöst wird, und die Aktualisierung der Position gesammelt.*/
    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    updateDisplay()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      self.eachSecond()
    }
    startLocationUpdates()
  }
    
  private func stopRun() {
    mapContainerView.isHidden = true
    launchPromptStackView.isHidden = false
    dataStackView.isHidden = true
    startButton.isHidden = false
    stopButton.isHidden = true
    
    //Stopt das tracken der Location
    locationManager.stopUpdatingLocation()
  }
  
  @IBAction func startTapped() {
    startRun()
  }
  
  @IBAction func stopTapped() {
    //User soll entscheiden können was passiert, wenn man stop drückt. Entweder "End run", "Cancel" oder "Save"
    let alertController = UIAlertController(title: "Run beenden?",
                                            message: "Willst du dein Training beenden?",
                                            preferredStyle: .actionSheet)
    alertController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Speichern", style: .default) { _ in
      self.stopRun()
      self.saveRun()
      self.performSegue(withIdentifier: .details, sender: nil)
    })
    alertController.addAction(UIAlertAction(title: "Verwerfen", style: .destructive) { _ in
      self.stopRun()
      _ = self.navigationController?.popToRootViewController(animated: true)
    })
        
    present(alertController, animated: true)
  }
  
}

extension NewRunViewController: SegueHandlerType {
  enum SegueIdentifier: String {
    case details = "RunDetailsViewController"
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segueIdentifier(for: segue) {
    case .details:
      let destination = segue.destination as! RunDetailsViewController
      destination.run = run
    }
  }
  
  private func startLocationUpdates() {
    locationManager.delegate = self
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
    locationManager.startUpdatingLocation()
  }
  
  private func saveRun() {
    let newRun = Run(context: CoreDataStack.context)
    newRun.distance = distance.value
    newRun.duration = Int16(seconds)
    newRun.timestamp = Date()
    
    for location in locationList {
      let locationObject = Location(context: CoreDataStack.context)
      locationObject.timestamp = location.timestamp
      locationObject.latitude = location.coordinate.latitude
      locationObject.longitude = location.coordinate.longitude
      newRun.addToLocations(locationObject)
    }
    
    CoreDataStack.saveContext()
    
    run = newRun
  }
}

/*Core Location meldet Standortaktualisierungen über den CLLocationManagerDelegate. Diese Delegiertenmethode wird jedes Mal
 aufgerufen, wenn Standort des Benutzers aktualisiert und stellt ein Array von CLLocation-Objekten bereit.*/

//Eine CLLocation enthält die latitude, longitude und timestamp
extension NewRunViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      
      //hier wird gecheckt, dass die Genauigkeit der Standortbestimmtung stimmt
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }

      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
      }

      locationList.append(newLocation)
    }
  }
}

extension NewRunViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}
