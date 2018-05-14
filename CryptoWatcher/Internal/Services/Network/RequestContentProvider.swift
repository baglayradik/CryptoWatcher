import Foundation
import Alamofire

enum RequestContentProvider: URLRequestConvertible {
    static let baseURLString = "https://min-api.cryptocompare.com/data"
    
    case getCoinPrice(String, String)
    case getAllCoinsPrice(String, String)
    case allCoins
    case getCoinFullData(String,String)
    case getHistoryOfDay(String,String,String)
    case getHistoryOfHour(String,String,String)
    
    var methodHTTP: Alamofire.HTTPMethod {
        switch self {
        case .getCoinPrice:
            return .get
        case .allCoins:
            return .get
        case .getAllCoinsPrice:
            return .get
        case .getCoinFullData:
            return .get
        case .getHistoryOfDay:
            return .get
        case .getHistoryOfHour:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getCoinPrice:
            return "/price"
        case .getAllCoinsPrice:
            return "/pricemulti"
        case .allCoins:
            return "/all/coinlist"
        case .getCoinFullData:
            return "/pricemultifull"
        case .getHistoryOfDay:
            return "/histoday"
        case .getHistoryOfHour:
            return "/histohour"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = URL(string: RequestContentProvider.baseURLString)!
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = methodHTTP.rawValue
        switch self {
        case .getCoinPrice(let coin, let currency):
            let parameters = ["fsym": coin, "tsyms": currency]
                 return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .getAllCoinsPrice(let coins, let currency):
             let parameters = ["fsyms": coins, "tsyms": currency]
             return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .getCoinFullData(let coin, let currency):
             let parameters = ["fsyms": coin, "tsyms": currency]
            return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .getHistoryOfDay(let coin,let currency, let limit):
            let parameters = ["fsym": coin, "tsym": currency, "limit": limit]
            return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        case .getHistoryOfHour(let coin,let currency, let limit):
            let parameters = ["fsym": coin, "tsym": currency, "limit": limit]
            return try URLEncoding.queryString.encode(urlRequest, with: parameters)
        default:
            return urlRequest
        }
    }
}
