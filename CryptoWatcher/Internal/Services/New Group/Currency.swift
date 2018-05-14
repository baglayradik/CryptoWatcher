struct CurrencyInfo: Codable {
    let name: String
    let cost: Double //in Preferences.baseCurrency
}

/*struct Currency {
    let name: String?
    let exchangeRates: [ExchangeRate]?
    
    init(dictionary: [String:[String:Double]]) {
        let key = dictionary.keys.first!
        self.name = key
        var tmpArray : [ExchangeRate] = []
        for (key,value) in dictionary[key]! {
            tmpArray.append(ExchangeRate(name: BaseCurrency(rawValue: key)!, cost: value))
        }
        self.exchangeRates = tmpArray
    }
    
    init(name: String, exchangeRatesDictionary: [String:Double]) {
        self.name = name
        var tmpArray : [ExchangeRate] = []
        for (key,value) in exchangeRatesDictionary {
            tmpArray.append(ExchangeRate(name: BaseCurrency(rawValue: key)!, cost: value))
        }
        self.exchangeRates = tmpArray
    }
}*/
