import Foundation

enum CrescendoLevel: CaseIterable, Equatable {
    case hard
    case medium
    case easy

    var allowedMistakes: Int {
        switch self {
        case .hard: return 1
        case .medium: return 3
        case .easy: return 5
        }
    }

    var displayName: String {
        switch self {
        case .hard: return "Hard"
        case .medium: return "Medium"
        case .easy: return "Easy"
        }
    }

    var symbol: String {
        switch self {
        case .hard: return "H"
        case .medium: return "M"
        case .easy: return "E"
        }
    }
}
