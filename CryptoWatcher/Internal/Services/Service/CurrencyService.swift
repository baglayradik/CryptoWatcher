import Foundation

enum CurrencyServiceErrors: Error {
    case InvalidFullName
    case InvalidShortName
}

protocol CurrencyServiceObserver: AnyObject {
    //  func onBaseCurrencyChange(newBaseCurrency: BaseCurrency)
    func onTrackedCoinsUpdate(coins: [String])
}

protocol CoinPriceChangeObserver: AnyObject {
    func onCoinPriceChange(newPrice: Double)
}

class CurrencyService {
    private let networkService = NetworkService()
    private var preferences: Preferences
    private var baseCurrency: BaseCurrency
    
    private var observers: [CurrencyServiceObserver] = []

    private var trackedCoins: [String] {
        return preferences.trackedCoins
    }
    
    var currencyList: [CurrencyInfo] = []
    
    private var currencyInfoMutex: NSLock = NSLock()
    private var cacheCoinList: ListCoins = ListCoins()
    private var cacheListOfAviableCoins: [String] = []
    private var cacheFullnameToShortnameDictionary: [String:String] = [:]
    
    private var coinPriceObservers: [(CoinPriceChangeObserver, String)] = []
    
    init(preferences: Preferences) {
        baseCurrency = preferences.baseCurrency
        
        self.preferences = preferences
        self.preferences.addObserver(self)
    }
    
    func updatePrices(completion: @escaping (RequestResult<[CurrencyInfo]>) -> Void) {
        let coins = preferences.trackedCoins.joined(separator: ",")
        networkService.getMultipleCoinsPrice(coin: coins, baseCurrency: baseCurrency.rawValue) { result in
            switch result {
            case .success(let dictionary): //TODO: clean and rename vars
                var prices: [CurrencyInfo] = []
                for object in dictionary {
                    prices.append(CurrencyInfo (name: object.key, cost: object.value.first!.value))
                }
                prices.sort { currency1, currency2 in
                    return self.preferences.trackedCoins.index(of: currency1.name)! < self.preferences.trackedCoins.index(of: currency2.name)!
                }
                for i in 0..<min(self.currencyList.count, prices.count) {
                    if prices[i].cost != self.currencyList[i].cost {
                        for (observer, coin) in self.coinPriceObservers {
                            if prices[i].name == coin {
                                observer.onCoinPriceChange(newPrice: prices[i].cost)
                            }
                        }
                    }
                }
                self.currencyList = prices
                completion(.success(prices))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func coinInfo(coin:String, completion: @escaping (RequestResult<CurrencyFullRaw>) -> Void) {
        networkService.getCoinFullData(coin: coin, baseCurrency: preferences.baseCurrency.rawValue ) { (result) in
            switch result {
            case .success(let dictionary):
                let raw = dictionary.raw.first?.value.first?.value
                completion(.success(raw!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCoinList(coin: String, completion: @escaping (RequestResult<Coin>) -> Void) {
        networkService.getCoinsList { (result) in
            switch result {
            case .success(let allCoins):
                if let coin = allCoins.data![coin] {
                    completion(.success(coin))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCoinPrice(coin: String, baseCurrency: String, completion: @escaping (RequestResult<Double>) -> Void) {
        networkService.getSingleCoinPrice(coin: coin, baseCurrency: baseCurrency) { result in
            switch result {
            case .success(let prices):
                if let price = prices[baseCurrency] {
                    completion(.success(price))
                }
                else {
                    completion(.failure(CurrencyServiceErrors.InvalidShortName))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHistoryOfDay(coin: String, baseCurrency: String, limit: String, completion: @escaping (RequestResult<[HistoryCoin]>) -> Void) {
        networkService.getHistoryOfDay(coin: coin, baseCurrency: baseCurrency, limit: limit) { result in
            switch result {
            case .success(let historyData):
                if let historyCoin = historyData.data {
                    completion(.success(historyCoin))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHistoryOfHour(coin: String, baseCurrency: String, limit: String, completion: @escaping (RequestResult<[HistoryCoin]>) -> Void) {
        networkService.getHistoryOfHour(coin: coin, baseCurrency: baseCurrency, limit: limit) { result in
            switch result {
            case .success(let historyData):
                if let historyCoin = historyData.data {
                    completion(.success(historyCoin))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cacheCoinList(list: ListCoins) {
        cacheCoinList = list
        
        for coin in list.data! {
            self.cacheListOfAviableCoins.append(coin.value.coinName!)
            self.cacheFullnameToShortnameDictionary[coin.value.coinName!] = coin.value.symbol!
        }
        
        cacheListOfAviableCoins.append("Euro")
        cacheListOfAviableCoins.append("Dollar")
        cacheListOfAviableCoins.append("Ruble")
        
        cacheFullnameToShortnameDictionary["Euro"] = "EUR"
        cacheFullnameToShortnameDictionary["Dollar"] = "USD"
        cacheFullnameToShortnameDictionary["Ruble"] = "RUB"

        self.cacheListOfAviableCoins.sort {str1, str2 in
            return str1.lowercased() < str2.lowercased()
        }
    }
    
    func getAviableCoins(completion: @escaping (RequestResult<[String]>) -> Void) {
        if cacheListOfAviableCoins.isEmpty {
            networkService.getCoinsList { result in
                self.currencyInfoMutex.lock()
                defer {
                    self.currencyInfoMutex.unlock()
                }
                switch result {
                case .success(let list):
                    self.cacheCoinList(list: list)
                    
                    completion(.success(self.cacheListOfAviableCoins))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        else {
            completion(.success(cacheListOfAviableCoins))
        }
    }
    
    func convertFullnameToShortname(fullname: String, completion: @escaping (RequestResult<String>) -> Void) {
        if cacheFullnameToShortnameDictionary.isEmpty {
            networkService.getCoinsList { result in
                self.currencyInfoMutex.lock()
                defer {
                    self.currencyInfoMutex.unlock()
                }
                switch result {
                case .success(let list):
                    self.cacheCoinList(list: list)
                    
                    switch self.cacheFullnameToShortnameDictionary[fullname] {
                    case .some(let shortName):
                        completion(.success(shortName))
                    case .none:
                        completion(.failure(CurrencyServiceErrors.InvalidFullName))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        else {
            switch self.cacheFullnameToShortnameDictionary[fullname] {
            case .some(let shortName):
                completion(.success(shortName))
            case .none:
                completion(.failure(CurrencyServiceErrors.InvalidFullName))
            }
        }
    }
    
    func addTrackedCoin(newCoin: String) throws {
        try preferences.addTrackedCoin(newCoin: newCoin)
    }
    
    func removeTrackedCoin(removingCoin: String) throws {
        try preferences.removeTrackedCoin(removingCoin: removingCoin)
    }
}

/*Call this methods if and only if you called convertFullnameToShortname or getAviableCoins.
 Otherwise application will be CRASHED!!!!!*/
extension CurrencyService {
    func convertFullnameToShortNameFromCache(fullname: String) throws -> String {
        if cacheFullnameToShortnameDictionary.isEmpty {
            fatalError("Read description of extension")
        }
        
        if let shortname = cacheFullnameToShortnameDictionary[fullname] {
            return shortname
        }
        else {
            throw CurrencyServiceErrors.InvalidFullName
        }
    }
}

extension CurrencyService: PreferencesObserver {
    func onBaseCurrencyChange(newBaseCurrency: BaseCurrency) {
        baseCurrency = newBaseCurrency
    }
    
    func onTrackedCoinsUpdate(coins: [String]) {
        for observer in observers {
            observer.onTrackedCoinsUpdate(coins: coins)
        }
    }
}

extension CurrencyService {
    func addObserver(_ observer: CurrencyServiceObserver) {
        assert(observers.index{$0 === observer} == nil)
        observers.append(observer)
    }
    
    func removeObserver(_ observer: CurrencyServiceObserver) {
        let observerIndex = observers.index{$0 === observer}
        assert(observerIndex != nil)
        observers.remove(at: observerIndex!)
    }
}

extension CurrencyService {
    func notifyWhenCoinPriceChange(observer: CoinPriceChangeObserver, coin: String) {
        coinPriceObservers.append((observer, coin))
    }
    
    func denotifyWhenCoinPriceChange(observer: CoinPriceChangeObserver) {
        coinPriceObservers = coinPriceObservers.filter { pair in
            return pair.0 !== observer
        }
    }
}
