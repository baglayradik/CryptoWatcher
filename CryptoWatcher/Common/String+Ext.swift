import Foundation

extension String {
    static func localized(_ identifier: String) -> String {
        let localizedString = NSLocalizedString(identifier, comment: "")
        assert(localizedString != identifier)
        
        return localizedString
    }
}
