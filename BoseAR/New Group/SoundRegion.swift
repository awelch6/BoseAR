import UserNotifications
import AVFoundation

enum SoundRegion: String {
    case EpicMusic = "EpicMusic"
    case Motown = "Motown"
    case None
    
    var trackId: String {
        switch self {
        case .EpicMusic:
            return "USKRS0326911"
        case .Motown:
            return "GBALB9900009"
        default:
            return "NOT IN REGION"
        }
    }
    
    public func displayNotification() {
        switch self {
         
        case .EpicMusic:
            let content = UNMutableNotificationContent()
            content.title = "You have entered the Epic Music Zone"
            content.body = "Listen to these amazing tracks!"
            content.sound = UNNotificationSound.default
 
            //Speak the notification
            let utterance = AVSpeechUtterance(string: "You are now entering the Epic Music Zone")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
            
            let synthesizer = AVSpeechSynthesizer()
            
            let request = UNNotificationRequest(identifier: "epicMusic", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    synthesizer.speak(utterance)
                }
            }
        case .Motown:
            let content = UNMutableNotificationContent()
            content.title = "You have entered the Motown Music Zone"
            content.body = "Listen to these amazing tracks!"
            content.sound = UNNotificationSound.default
            
            //Speak the notification
            let utterance = AVSpeechUtterance(string: "You are now entering the Motown Music Zone")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate

            let synthesizer = AVSpeechSynthesizer()
            
            let request = UNNotificationRequest(identifier: "motownMusic", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    synthesizer.speak(utterance)
                }
            }
        default: break
        }
    }
}
