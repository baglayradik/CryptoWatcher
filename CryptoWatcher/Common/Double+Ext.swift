import Foundation

extension Double {
    static func roundToPlaces(places: Double) -> String{
        let aStr = String(format: "%5.2f", places)
        return aStr
    }
    
    func toString() -> String {
        var result = String(format: "%.10f",self).replacingOccurrences(of: ".", with: String.localized("Shared.DecimalDelimeter"))
        while result.last! == "0" {
            result = String(result.dropLast())
        }
        if result.last! == String.localized("Shared.DecimalDelimeter").first! {
            result = String(result.dropLast())
        }
        return result
    }
}
