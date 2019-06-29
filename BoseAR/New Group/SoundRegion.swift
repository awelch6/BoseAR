import Foundation

enum SoundRegion {
    case BirdRegion
    case Jungle
    case None
    
    var soundUrl: String {
        switch self {
        case .BirdRegion:
            return "Nature-sounds-birds"
        case .Jungle:
            return "JUNGLE MP3"
        default:
            return "NOT IN REGION"
        }
    }
}
