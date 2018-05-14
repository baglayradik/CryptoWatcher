
import Foundation

extension Formatter {
    enum FormatterType {
        case day
        case hour
    }
    
    static func timeFormatter(type: FormatterType, times: [Int]) -> [String] {
        let time = DateFormatter()
        var tmpArray:[String] = []
        switch type {
        case .day:
            time.dateFormat = "dd MMM"
        case .hour:
            time.dateFormat = "dd MMM, HH:mm"
        }
        for i in times {
            let date = Date(timeIntervalSince1970: TimeInterval(i))
            let stringTime = time.string(from: date)
            tmpArray.append(stringTime)
        }
        return tmpArray
    }
}
