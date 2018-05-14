
import Foundation


struct RootCurrency: Codable {
    
    let raw:  [String:[String:CurrencyFullRaw]]
    let display: [String:[String:CurrencyFullDisplay]]
    
    enum CodingKeys: String,CodingKey {
        case display = "DISPLAY"
        case raw = "RAW"
    }
}

struct CurrencyFullDisplay: Codable {
    
    let fromSymbol: String
    let price: String
    let changePct24Hour: String
    let lastUpdate: String
    let change24Hour: String
    let volume24Hour: String
    let mktCap: String
    
    enum CodingKeys: String,CodingKey {
        case fromSymbol = "FROMSYMBOL"
        case price = "PRICE"
        case changePct24Hour = "CHANGEPCT24HOUR"
        case lastUpdate = "LASTUPDATE"
        case change24Hour = "CHANGE24HOUR"
        case volume24Hour = "VOLUME24HOUR"
        case mktCap = "MKTCAP"
    }
}


struct CurrencyFullRaw: Codable {
    
    let fromSymbol: String
    let price: Double
    let changePct24Hour: Double
    let lastUpdate: Int
    let change24Hour: Double
    let volume24Hour: Double
    let mktCap: Double
    let volume24HourTo: Double
    let supply: Double
    
    enum CodingKeys: String,CodingKey {
        case fromSymbol = "FROMSYMBOL"
        case price = "PRICE"
        case changePct24Hour = "CHANGEPCT24HOUR"
        case lastUpdate = "LASTUPDATE"
        case change24Hour = "CHANGE24HOUR"
        case volume24Hour = "VOLUME24HOUR"
        case mktCap = "MKTCAP"
        case volume24HourTo = "VOLUME24HOURTO"
        case supply = "SUPPLY"
    }
}

extension CurrencyFullRaw {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        var price: Any
        var changePct24Hour: Any
        var fromSymbol: Any
        var lastUpdate: Any
        var change24Hour: Any
        var volume24Hour: Any
        var mktCap: Any
        var volume24HourTo: Any
        var supply: Any
        
        do {
            changePct24Hour = try container.decode(Double.self, forKey: .changePct24Hour)
            price = try container.decode(Double.self, forKey: .price)
            fromSymbol = try container.decode(String.self, forKey: .fromSymbol)
            lastUpdate = try container.decode(Int.self, forKey: .lastUpdate)
            change24Hour = try container.decode(Double.self, forKey: .change24Hour)
            volume24Hour = try container.decode(Double.self, forKey: .volume24Hour)
            mktCap = try container.decode(Double.self, forKey: .mktCap)
            volume24HourTo = try container.decode(Double.self, forKey: .volume24HourTo)
            supply = try container.decode(Double.self, forKey: .supply)
            
            self.init(fromSymbol: fromSymbol as! String,
                      price: price as! Double,
                      changePct24Hour: changePct24Hour as! Double,
                      lastUpdate: lastUpdate as! Int,
                      change24Hour: change24Hour as! Double,
                      volume24Hour: volume24Hour as! Double,
                      mktCap: mktCap as! Double,
                      volume24HourTo: volume24HourTo as! Double,
                      supply: supply as! Double)
        }
        catch {
            changePct24Hour = try! container.decode(Double.self, forKey: .changePct24Hour)
            price = try container.decode(String.self, forKey: .price)
            fromSymbol = try container.decode(String.self, forKey: .fromSymbol)
            lastUpdate = try container.decode(Int.self, forKey: .lastUpdate)
            change24Hour = try container.decode(Double.self, forKey: .change24Hour)
            volume24Hour = try container.decode(Double.self, forKey: .volume24Hour)
            mktCap = try container.decode(Double.self, forKey: .mktCap)
            volume24HourTo = try container.decode(Double.self, forKey: .volume24HourTo)
            supply = try container.decode(Double.self, forKey: .supply)
            
            self.init(fromSymbol: fromSymbol as! String,
                      price:Double(price as! String)!,
                      changePct24Hour: changePct24Hour as! Double,
                      lastUpdate: lastUpdate as! Int,
                      change24Hour: change24Hour as! Double,
                      volume24Hour: volume24Hour as! Double,
                      mktCap: mktCap as! Double,
                      volume24HourTo: volume24HourTo as! Double,
                      supply: supply as! Double)
        }
    }
}



