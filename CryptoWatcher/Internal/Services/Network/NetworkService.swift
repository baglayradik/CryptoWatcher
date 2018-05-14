enum RequestResult<T: Codable> {
    case success(T)
    case failure(Error)
}

class NetworkService {
    func getSingleCoinPrice(coin: String, baseCurrency: String, completion: @escaping (RequestResult<[String:Double]>) -> Void) {
        let apiTask = APITask<[String:Double]>(urlRequest: try! RequestContentProvider.getCoinPrice(coin,baseCurrency).asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
   
    func getMultipleCoinsPrice(coin: String, baseCurrency: String, completion: @escaping (RequestResult<[String:[String:Double]]>) -> Void) {
        let apiTask = APITask<[String:[String:Double]]>(urlRequest: try! RequestContentProvider.getAllCoinsPrice(coin,baseCurrency).asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
    
    func getCoinsList(completion: @escaping (RequestResult<ListCoins>) -> Void) {
        let apiTask = APITask<ListCoins>(urlRequest: try! RequestContentProvider.allCoins.asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
    
    func getCoinFullData(coin:String, baseCurrency: String, completion: @escaping
        (RequestResult<RootCurrency>) -> Void) {
        let apiTask = APITask<RootCurrency>(urlRequest: try! RequestContentProvider.getCoinFullData(coin, baseCurrency).asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
    
    func getHistoryOfDay(coin: String, baseCurrency: String, limit: String, completion: @escaping (RequestResult<RootHistoryData>) -> Void) {
        let apiTask = APITask<RootHistoryData>(urlRequest: try! RequestContentProvider.getHistoryOfDay(coin, baseCurrency, limit).asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
    
    func getHistoryOfHour(coin: String, baseCurrency: String, limit: String, completion: @escaping (RequestResult<RootHistoryData>) -> Void) {
        let apiTask = APITask<RootHistoryData>(urlRequest: try! RequestContentProvider.getHistoryOfHour(coin, baseCurrency, limit).asURLRequest(), completion: completion)
        let requestManager = RequestManager()
        requestManager.runTask(apiTask)
    }
}

