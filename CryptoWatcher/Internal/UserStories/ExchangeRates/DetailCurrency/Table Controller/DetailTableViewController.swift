

import UIKit

class DetailTableViewController: UITableViewController {
    
    
    @IBOutlet private weak var priceStaticLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var priceView: UIView!
    
    @IBOutlet private weak var marketCapStaticLabel: UILabel!
    @IBOutlet private weak var marketCapLabel: UILabel!
    @IBOutlet private weak var marketCapView: UIView!
    
    @IBOutlet private weak var volumeStaticLabel: UILabel!
    @IBOutlet private weak var volumeLabel: UILabel!
    @IBOutlet private weak var volumeStaticView: UIView!
    
    @IBOutlet private weak var volumeBaseCurrencyStaticLabel: UILabel!
    @IBOutlet private weak var volumeBaseCurrencyLabel: UILabel!
    @IBOutlet private weak var volumeBaseCurrencyView: UIView!
    
    @IBOutlet private weak var supplyStaticLabel: UILabel!
    @IBOutlet private weak var supplyLabel: UILabel!
    @IBOutlet private weak var supplyView: UIView!
    
    @IBOutlet private weak var changeStaticLabel: UILabel!
    @IBOutlet private weak var changeLabel: UILabel!
    @IBOutlet private weak var changeView: UIView!
    
    var context: Context?
    var currency: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        context?.currencyService.coinInfo(coin: currency!, completion: { (result) in
            switch result {
            case .success(let dictionary):
                guard let baseCurrency = self.context?.preferences.baseCurrency.rawValue, let baseCurrencySymbol = self.context?.preferences.baseCurrency.getCurrencySymbol() else {
                    return
                }

                self.priceStaticLabel?.text = " \(String.localized("Detail.Price")),\(baseCurrency)"
                self.priceLabel?.text = "\(NumberFormatter.formatDecimal(number: dictionary.price)) \(baseCurrencySymbol) "
                
                self.volumeStaticLabel?.text = "\(String.localized("Detail.Volume")), \(dictionary.fromSymbol)"
                self.volumeLabel?.text = "\(NumberFormatter.formatDecimal(number: dictionary.volume24Hour)) \(baseCurrencySymbol)"
                
                self.marketCapStaticLabel?.text = "\(String.localized("Detail.MarketCup")), \(baseCurrency)"
                self.marketCapLabel?.text = "\(NumberFormatter.formatDecimal(number: dictionary.mktCap)) \(baseCurrencySymbol)"
                
                self.volumeBaseCurrencyStaticLabel?.text = "\(String.localized("Detail.Volume")), \(baseCurrency)"
                self.volumeBaseCurrencyLabel?.text = "\(NumberFormatter.formatDecimal(number: dictionary.volume24HourTo)) \(baseCurrencySymbol)"
               
                self.supplyStaticLabel?.text = "\(String.localized("Detail.CoinsAvailable"))"
                self.supplyLabel?.text = "\(NumberFormatter.formatDecimal(number: dictionary.supply))"
        
                self.changeStaticLabel?.text = "\(String.localized("Detail.Change"))"
                self.changeLabel?.text = "\(Double.roundToPlaces(places: dictionary.changePct24Hour)) %"
                
            case .failure(let error):
                print(error)
            }
        })
        
    }
}

extension DetailTableViewController {
    func configureView() {
        priceView.layer.borderWidth = 0.2
        priceView.layer.borderColor = UIColor.gray.cgColor
        
        marketCapView.layer.borderWidth = 0.2
        marketCapView.layer.borderColor = UIColor.gray.cgColor
        
        volumeStaticView.layer.borderWidth = 0.2
        volumeStaticView.layer.borderColor = UIColor.gray.cgColor
        
        volumeBaseCurrencyView.layer.borderWidth = 0.2
        volumeBaseCurrencyView.layer.borderColor = UIColor.gray.cgColor
        
        supplyView.layer.borderWidth = 0.2
        supplyView.layer.borderColor = UIColor.gray.cgColor
        
        changeView.layer.borderWidth = 0.2
        changeView.layer.borderColor = UIColor.gray.cgColor
    }
}
