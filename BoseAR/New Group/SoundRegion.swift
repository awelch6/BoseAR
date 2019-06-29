import Foundation

enum SoundRegion {
    case BirdRegion
    case Jungle
    
    var soundUrl: String {
        switch self {
        case .BirdRegion:
            return "Nature-sounds-birds"
        default:
            return "JUNGLE MP3"
        }
    }
}
