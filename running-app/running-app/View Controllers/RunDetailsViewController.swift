import UIKit
import MapKit
import CoreData

class RunDetailsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
    
//Context wird von PastRunViewController übergeben
var managedContext : NSManagedObjectContext?
  
  var run: Run!
    
//Wird von PastRunViewController übergeben
    var detailItem: Run? {
        didSet {
//            // Update the view.
//
//            //detailItem ist neue Person
//            //run = detailItem
//            print(run)
//            configureView()
        }
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //run = detailItem
    configureView()
  }
  
  private func configureView() {
    let distance = Measurement(value: run.distance, unit: UnitLength.meters)
    let seconds = Int(run.duration)
    let formattedDistance = FormatDisplay.distance(distance)
    let formattedDate = FormatDisplay.date(run.timestamp)
    let formattedTime = FormatDisplay.time(seconds)
    let formattedPace = FormatDisplay.pace(distance: distance,
                                           seconds: seconds,
                                           outputUnit: UnitSpeed.kilometersPerHour)
    
    distanceLabel.text = "Distance:  \(formattedDistance)"
    dateLabel.text = formattedDate
    timeLabel.text = "Time:  \(formattedTime)"
    paceLabel.text = "Pace:  \(formattedPace)"
    
    //Map laden
    loadMap()
  }
  
  /*Macht, dass nur die Region des laufes gezeigt wird.*/
  private func mapRegion() -> MKCoordinateRegion? {
    guard
      let locations = run.locations,
      locations.count > 0
    else {
      return nil
    }
      
    let latitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.latitude
    }
      
    let longitudes = locations.map { location -> Double in
      let location = location as! Location
      return location.longitude
    }
      
    let maxLat = latitudes.max()!
    let minLat = latitudes.min()!
    let maxLong = longitudes.max()!
    let minLong = longitudes.min()!
      
    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                        longitude: (minLong + maxLong) / 2)
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                longitudeDelta: (maxLong - minLong) * 1.3)
    return MKCoordinateRegion(center: center, span: span)
  }
  
  /*MKOverlay zeichnet die Linie*/
  private func polyLine() -> MKPolyline {
    guard let locations = run.locations else {
      return MKPolyline()
    }
   
    let coords: [CLLocationCoordinate2D] = locations.map { location in
      let location = location as! Location
      return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    return MKPolyline(coordinates: coords, count: coords.count)
  }
  
  
  private func loadMap() {
    guard
      let locations = run.locations,
      locations.count > 0,
      let region = mapRegion()
    else {
        let alert = UIAlertController(title: "Error",
                                      message: "Sorry, this run has no locations saved",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
        return
    }
      
    mapView.setRegion(region, animated: true)
    mapView.addOverlay(polyLine())
  }
  
}

/*Jedes Mal, wenn MapKit ein Overlay anzeigen möchte, fragt es den Delegate nach etwas, das dieses Overlay darstellt.*/
extension RunDetailsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .black
    renderer.lineWidth = 3
    return renderer
  }
}
