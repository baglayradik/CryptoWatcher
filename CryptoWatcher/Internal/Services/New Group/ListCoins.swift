import Foundation

struct ListCoins: Codable {
    let data: [String:Coin]?
    
    init() {
        data = [:]
    }
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

struct Coin: Codable {
    static let baseImageUrl = "https://www.cryptocompare.com"
    
    let id: String?
    let symbol: String?
    let coinName: String?
    let fullName: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case coinName = "CoinName"
        case fullName = "FullName"
        case id = "Id"
        case symbol = "Symbol"
        case imageUrl = "ImageUrl"
    }
}
