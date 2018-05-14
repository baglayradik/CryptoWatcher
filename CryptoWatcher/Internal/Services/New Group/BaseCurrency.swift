enum BaseCurrency: String {
    case usd = "USD"
    case rub = "RUB"
    case btc = "BTC"
    case eur = "EUR"
}

extension BaseCurrency {
    func getCurrencySymbol() -> String {
        switch self {
        case .usd:
            return "$"
        case .eur:
            return "€"
        case .rub:
            return "₽"
        case .btc:
            return "BTC"
        }
    }
}


