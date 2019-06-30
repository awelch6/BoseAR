import UIKit
import BoseWearable
import simd
import MapKit
import AVFoundation

class BeginQastingViewController: UIViewController {
    private var globalSession: WearableDeviceSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionManager.shared.delegate = self
    }
    
    @IBAction func touchedBeginQasting(_ sender: Any) {
        SessionManager.shared.startConnection()
    }
    
}

extension BeginQastingViewController: SessionManagerDelegate {
    func session(_ session: WearableDeviceSession, didOpen: Bool) {
        globalSession = session
        performSegue(withIdentifier: "goToMainVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMainVC" {
            if let destinationVC = segue.destination as? ViewController {
                destinationVC.session = globalSession
            }
        }
    }
}
