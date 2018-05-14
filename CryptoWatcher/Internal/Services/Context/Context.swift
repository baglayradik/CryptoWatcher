import Foundation

protocol Contextual {
    var context: Context? { get set }
}

class Context {
    let preferences: Preferences
    let currencyService: CurrencyService
    let imageService: ImageService
    
    init(preferences: Preferences) {
        self.preferences = preferences
        currencyService = CurrencyService(preferences: preferences)
        imageService = ImageService(baseUrl: URL(string: "https://www.cryptocompare.com")!) // TODO: inject
    }
}

extension Context {
    static func createContext() -> Context {
        return Context(preferences: Preferences())
    }
}

