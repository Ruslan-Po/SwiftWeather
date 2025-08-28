enum Greetings {
    case morning
    case day
    case evening
    case night
}


struct GreetingsMessage {
    let greeting: Greetings
    
    var text: String {
        switch greeting {
        case .morning: return "Good morning"
        case .day: return "Good afternoon"
        case .evening: return "Good evening"
        case .night: return "Good night"
        }
    }
}

