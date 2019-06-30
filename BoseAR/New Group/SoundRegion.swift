import UserNotifications

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
            
            let request = UNNotificationRequest(identifier: "epicMusic", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        case .Motown:
            let content = UNMutableNotificationContent()
            content.title = "You have entered the Epic Music Zone"
            content.body = "Listen to these amazing tracks!"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "motownMusic", content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        default: break
        }
    }
}
