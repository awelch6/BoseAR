import Foundation

enum SoundRegion: String {
    case EpicMusic = "EpicMusic"
    case Motown = "Motown"
    case None
    
    var soundUrl: String {
        switch self {
        case .EpicMusic:
            return "Eye-of-the-Tiger"
        case .Motown:
            return "cloud-nine"
        default:
            return "NOT IN REGION"
        }
    }
}
