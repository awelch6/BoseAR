import Foundation

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
}
