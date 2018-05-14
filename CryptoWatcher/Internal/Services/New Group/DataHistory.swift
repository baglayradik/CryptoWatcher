

import Foundation

struct RootHistoryData: Codable {
    
    let response:  String?
    let type: Int?
    let aggregated: Bool?
    let data: [HistoryCoin]?

    enum CodingKeys: String, CodingKey {
        case response = "Response"
        case type = "Type"
        case aggregated = "Aggregated"
        case data = "Data"
    }
}

struct HistoryCoin: Codable {
    
    let time: Int?
    let close: Double?
    let high: Double?
    let open: Double?
    let volumefrom: Double?
    let volumeto: Double?
    
    enum CodingKeys: String, CodingKey {
        case time = "time"
        case close = "close"
        case high = "high"
        case open = "open"
        case volumefrom = "volumefrom"
        case volumeto = "volumeto"
    }
}
