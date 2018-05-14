import UIKit

class CurrencyTableViewCell: UITableViewCell {
    var context: Context?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changePriceLabel: UILabel!
    @IBOutlet weak var iconCurrencyImage: UIImageView!
}

extension CurrencyTableViewCell: CoinPriceChangeObserver {
    func onCoinPriceChange(newPrice: Double) {
        priceLabel.text = "\(NumberFormatter.formatDecimal(number: newPrice)) \(context!.preferences.baseCurrency.getCurrencySymbol())"
    }
}
