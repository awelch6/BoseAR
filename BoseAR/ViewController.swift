import UIKit
import BoseWearable
import simd
import MapKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var headingAccuracyValue: UILabel!
    @IBOutlet weak var currentSoundzone: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var cardinalHeading: UILabel!
    @IBOutlet weak var headingValue: UILabel!
    @IBOutlet weak var headingIndicatorView: HeadingIndicator!

    public var session: WearableDeviceSession?
    
    // BOSE AR SDK Properties
    private var token: ListenerToken?
    var sensorDispatch = SensorDispatch(queue: .main)
    private var magneticHeadingDegrees: Double?
    
    var cardinalDirection: CardinalDirection = .InBetween
    
    // CUSTOM MANAGERS
    private let trackManager = TrackManager()
    
    private var isPlayingPreview: Bool = false
    
    // SOUND REGIONS
    private var soundRegion: SoundRegion = .None {
        didSet {
            
            //Do nothing if the same region gets passed in twice
            if oldValue == soundRegion {
                return
            }
            
            trackManager.stop()
            
            soundRegion.displayNotification()

            if (soundRegion == .None) {
                currentSoundzone.text = "NOT IN ANY SOUND ZONE"
                return
            }
            
            currentSoundzone.text = "\(soundRegion)"
            
            trackManager.enqueue(soundRegion.trackId)
        }
    }
    
    let epicMusicRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 42.365360, longitude: -83.071234), radius: 100, identifier: SoundRegion.EpicMusic.rawValue)
    let motownRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 42.364542, longitude: -83.073900), radius: 100, identifier: SoundRegion.Motown.rawValue)

    // CORE LOCATION
    let locationManager = CLLocationManager()
    var isFirstLocationUpdate: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trackManager.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        
        sensorDispatch.handler = self
        listenForSensors(session!)
        listenForGestures(session!)
        
        token = session!.device?.addEventListener(queue: .main) { [weak self] event in
            self?.wearableDeviceEvent(event)
        }
        mapView.delegate = self
        
        checkLocationAuthStatus()
        monitorLocationAroundRegion(region: motownRegion)
        monitorLocationAroundRegion(region: epicMusicRegion)
    }
}

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

            config.enable(sensor: .rotation, at: ._20ms)
            config.enable(sensor: .accelerometer, at: ._20ms)
            config.enable(sensor: .gameRotation, at: ._20ms)
            config.enable(sensor: .orientation, at: ._20ms)
            config.enable(sensor: .magnetometer, at: ._20ms)
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
            break
        }
    }
}

extension ViewController: SensorDispatchHandler {
    
    enum CardinalDirection: String {
        case North = "North"
        case South = "South"
        case East = "East"
        case West = "West"
        case InBetween = "InBetween"
    }
    
    func receivedGesture(type: GestureType, timestamp: SensorTimestamp) {
        print("Gesture Type")
        if type == .doubleTap && soundRegion == .Motown {
            if isPlayingPreview {
                trackManager.stop()
                trackManager.enqueue(soundRegion.trackId)
                isPlayingPreview = false
                
                let utterance = AVSpeechUtterance(string: "You are now leaving preview mode.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            } else {
                if case .East = cardinalDirection {
                    //Speak the notification
                    let utterance = AVSpeechUtterance(string: "You are now previewing Epic Zone.")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                    
                    trackManager.stop()
                    trackManager.enqueue(SoundRegion.EpicMusic.trackId)
                    isPlayingPreview = true
                } else {
                    let utterance = AVSpeechUtterance(string: "No preview available.")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
            }
        }

        if type == .doubleTap && soundRegion == .EpicMusic {
            if isPlayingPreview {
                trackManager.stop()
                
                let utterance = AVSpeechUtterance(string: "You are now leaving preview mode.")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
                trackManager.enqueue(soundRegion.trackId)
                isPlayingPreview = false
            } else {
                if case .West = cardinalDirection {
                    //Speak the notification
                    let utterance = AVSpeechUtterance(string: "You are now previewing Motown Zone.")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                    
                    trackManager.stop()
                    trackManager.enqueue(SoundRegion.Motown.trackId)
                    isPlayingPreview = true
                } else {
                    let utterance = AVSpeechUtterance(string: "No preview available.")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
            }
        }
    }
    
    func getCardinalDirectionFromYaw(yaw: Double, accuracy: QuaternionAccuracy) {
        switch yaw {
        case -45 ..< 45:
            cardinalDirection = .North
            
        case 45 ..< 135:
            cardinalDirection = .East
            
        case 135 ..< 180:
            cardinalDirection = .South
        case -180 ..< -135:
            cardinalDirection = .South
            
        case -135 ..< -45:
            cardinalDirection = .West
            
        default:
            cardinalDirection = .InBetween
        }
        
        cardinalHeading.text = "Cardinal Heading: \(cardinalDirection.rawValue)"
    }
    
    func receivedRotation(quaternion: Quaternion, accuracy: QuaternionAccuracy, timestamp: SensorTimestamp) {
        
        let qMap = Quaternion(ix: 1, iy: 0, iz: 0, r: 0)
        let qResult = quaternion * qMap
        let yaw = -qResult.zRotation
        
        // The quaternion yaw value is the heading in radians. Convert to degrees.
        magneticHeadingDegrees = yaw * 180 / Double.pi

        updateNeedleHeading(magneticHeadingDegrees!)
        updateHeadingDisplay(accuracy: accuracy)
    }
    
    private func updateNeedleHeading(_ yaw: Double) {

//        let location:MKUserLocation = self.mapView.userLocation
//        let cordinate:CLLocationCoordinate2D = location.coordinate;
//
//        let circle = MKCircle(center: cordinate, radius: 10.0)
//
//
//        mapView.addOverlay(circle)
//
        self.headingIndicatorView.degrees = CGFloat(yaw);
        self.headingIndicatorView.setNeedsDisplay()

    }

    private func updateHeadingDisplay(accuracy: QuaternionAccuracy) {
        let heading = magneticHeadingDegrees
        
        // The desired heading value may be nil. See the documentation for `magneticHeadingDegrees` and `trueHeadingDegrees` to see why.
        if let h = heading {
            headingValue.text = "Heading Value: \(format(degrees: h))"
            getCardinalDirectionFromYaw(yaw: h, accuracy: accuracy)
        }
        else {
            headingValue.text = "-"
        }
        headingAccuracyValue.text = "Heading Accuracy: \(format(radians: accuracy.estimatedAccuracy))"
    }
}

extension ViewController: CLLocationManagerDelegate {
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func determineInitialRegion(initialUserCoordinate: CLLocationCoordinate2D) {
        if motownRegion.contains(initialUserCoordinate) {
            soundRegion = .Motown
        } else if epicMusicRegion.contains(initialUserCoordinate) {
            soundRegion = .EpicMusic
        } else {
            soundRegion = .None
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        mapView.showsUserLocation = true
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    // todo  sync HEading indicator view with userloacation

        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        self.mapView.setRegion(region, animated: true)
        
        if location.horizontalAccuracy > 0 {
            if isFirstLocationUpdate {
                determineInitialRegion(initialUserCoordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                isFirstLocationUpdate = false
            }

            if motownRegion.contains(location.coordinate) {
                soundRegion = .Motown
            } else if epicMusicRegion.contains(location.coordinate) {
                soundRegion = .EpicMusic
            } else {
                soundRegion = .None
            }
        }
        
        latitude.text = "LATITUDE: \(location.coordinate.latitude)"
        longitude.text = "LONGITUDE: \(location.coordinate.longitude)"
    }
    
    func monitorLocationAroundRegion(region: CLCircularRegion) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                locationManager.startMonitoring(for: region)
                circleOverlay(center: region.center, radius: 100)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did enter region \(region)")

        if region.identifier == SoundRegion.Motown.rawValue {
            soundRegion = .Motown
        } else if region.identifier == SoundRegion.EpicMusic.rawValue {
            soundRegion = .EpicMusic
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Did exit region \(region)")
        soundRegion = .None
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
}

extension ViewController: TrackManagerDelegate {
    func player(_ player: AVPlayer, didFinishPlaying: Bool) {
        print("Song did finish playing.")
    }
}
