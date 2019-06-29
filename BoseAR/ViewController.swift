import UIKit
import BoseWearable
import simd
import CoreLocation
import MapKit
import Foundation

class ViewController: UIViewController {
    
    var sensorDispatch = SensorDispatch(queue: .main)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    
    private var token: ListenerToken?

    let locationManager = CLLocationManager()
    
    var isFirstLocationUpdate: Bool = true
    
    let region1 = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 42.363552, longitude: -83.073319), radius: 50, identifier: "region1")
    let region2 = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 42.364542, longitude: -83.073900), radius: 50, identifier: "region2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        checkLocationAuthStatus()
        mapView.delegate = self
        
        monitorLocationAroundRegion(region: region1)
        monitorLocationAroundRegion(region: region2)
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
    
    func determineInitialRegion(initialUserCoordinate: CLLocationCoordinate2D) -> CLCircularRegion? {
        if region1.contains(initialUserCoordinate) {
            return region1
        } else if (region2.contains(initialUserCoordinate)) {
            return region2
        } else {
            return nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
//            locationManager.stopUpdatingLocation()
            mapView.showsUserLocation = true
            
            if (isFirstLocationUpdate) {
                determineInitialRegion(initialUserCoordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                isFirstLocationUpdate = false
            }
            
            latitude.text = "LATITUDE: \(location.coordinate.latitude)"
            longitude.text = "LONGITUDE: \(location.coordinate.longitude)"
        }
    }
    
    func monitorLocationAroundRegion(region: CLCircularRegion) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                let maxDistance = locationManager.maximumRegionMonitoringDistance
                
                locationManager.startMonitoring(for: region)
                circleOverlay(center: region.center, radius: 50)
                circleOverlay(center: region.center, radius: 50)
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
    func circleOverlay(center: CLLocationCoordinate2D, radius: Int) {
        let circle = MKCircle(center: center, radius: CLLocationDistance(radius))
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
