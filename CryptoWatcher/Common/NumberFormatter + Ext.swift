import Foundation

extension NumberFormatter {
    static func formatDecimal(number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale.current
        return formatter.string(from: NSNumber(value: number))!
    }
    
    static func formatDecimal(number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = NSLocale.current
        return formatter.string(from: NSNumber(value: number))!
    }
}
