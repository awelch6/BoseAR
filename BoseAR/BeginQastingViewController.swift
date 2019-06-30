import UIKit
import BoseWearable
import simd
import MapKit
import AVFoundation

class BeginQastingViewController: UIViewController {
    private var globalSession: WearableDeviceSession?
    
    @IBOutlet weak var beginQastingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SessionManager.shared.delegate = self
        beginQastingButton.layer.cornerRadius = 10
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
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
