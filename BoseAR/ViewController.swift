import UIKit
import BoseWearable
import simd
import MapKit
import AVFoundation

class ViewController: UIViewController {
    
    var sensorDispatch = SensorDispatch(queue: .main)
    var trackManager = TrackManager()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    
    private var token: ListenerToken?

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trackManager.delegate = self
        
        NetworkManager.shared.requestTracks { (tracks, error) in
            self.trackManager.enqueue(track: tracks[5])
        }
        
        locationManager.delegate = self
        checkLocationAuthStatus()
        mapView.delegate = self

        let location1 = CLLocation(latitude: 42.363552, longitude: -83.073319)
        let location2 = CLLocation(latitude: 42.364542, longitude: -83.073900)
        
        monitorLocationAroundRegion(location: location1, identifier: "location1")
        monitorLocationAroundRegion(location: location2, identifier: "location2")
        
//        SessionManager.shared.startConnection()
        SessionManager.shared.delegate = self
    }
}

// MARK: Setup Listeners

extension ViewController {
    private func listenForGestures(_ session: WearableDeviceSession) {
        session.device?.configureGestures({ (config) in
            config.disableAll()
            config.set(gesture: .doubleTap, enabled: true)
            config.set(gesture: .headNod, enabled: true)
        })
    }
    
    private func listenForSensors(_ session: WearableDeviceSession) {
        session.device?.configureSensors { config in
            // Here, config is the current sensor config. We begin by turning off
            // all sensors, allowing us to start with a "clean slate."
            config.disableAll()

            // Enable the rotation and accelerometer sensors
            config.enable(sensor: .rotation, at: ._20ms)
            config.enable(sensor: .accelerometer, at: ._20ms)
            config.enable(sensor: .gyroscope, at: ._20ms)
        }
    }
    
    private func wearableDeviceEvent(_ event: WearableDeviceEvent) {
        switch event {
        case .didWriteGestureConfiguration:
            print("did write gesture config")
        case .didUpdateGestureConfiguration:
            print("success updated gesture")
        case .didFailToWriteGestureConfiguration(let error):
            print("we have an err", error)
        default:
            print("default")
            break
        }
    }
}

extension ViewController: SessionManagerDelegate {
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        sensorDispatch.handler = self
        listenForSensors(session)
        listenForGestures(session)
        
        token = session.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
    }
}

extension ViewController: SensorDispatchHandler {
    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap

        let pitch = qResult.xRotation
        let roll = qResult.yRotation
        let yaw = -qResult.zRotation
    }


    func receivedGyroscope(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
        let pitch = vector.x
        let roll = vector.y
        let yaw = vector.z
    }
    
    func receivedGesture(type: GestureType, timestamp: SensorTimestamp) {
        print(type)
    }
//    func receivedAccelerometer(vector: Vector, accuracy: VectorAccuracy, timestamp: SensorTimestamp) {
//        xValue.text = format(decimal: vector.x)
//        yValue.text = format(decimal: vector.y)
//        zValue.text = format(decimal: vector.z)
//    }
}

extension ViewController: CLLocationManagerDelegate {
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
//            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = true
//            let location = locations.last as! CLLocation
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            region.center = mapView.userLocation.coordinate
//            mapView.setRegion(region, animated: true)
        
            latitude.text = "LATITUDE: \(location.coordinate.latitude)"
            longitude.text = "LONGITUDE: \(location.coordinate.longitude)"
            
        }
    }
    
    func monitorLocationAroundRegion(location: CLLocation, identifier: String) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                let region = CLCircularRegion(center: location.coordinate, radius: 50, identifier: identifier)
                
                let maxDistance = locationManager.maximumRegionMonitoringDistance
                
                locationManager.startMonitoring(for: region)
                circleOverlay(location: location, radius: 50)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Something happened with the region.")
        
        if region.identifier == "region1" {
            print("Region 1")
        } else if region.identifier == "region2" {
            print("Region 2")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("A region was exited.")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

extension ViewController: MKMapViewDelegate {
    func circleOverlay(location: CLLocation, radius: Int) {
        let circle = MKCircle(center: location.coordinate, radius: CLLocationDistance(radius))
        mapView.addOverlay(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blue
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        print("added an overlay")
    }
}

extension ViewController: TrackManagerDelegate {
    func player(_ player: AVPlayer, didFinishPlaying: Bool) {
        print("Song did finish playing.")
    }
}
