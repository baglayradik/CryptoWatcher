import UIKit

protocol ExchangeRatesPreferencesViewControllerDelegate: AnyObject {
    func exchangeRatesViewControllerDidTouchSaveButton(sender: ExchangeRatesPreferencesViewController, newBaseCurrency: BaseCurrency?)
}

class ExchangeRatesPreferencesViewController: UIViewController, Contextual {
    static let storyboardIdentifier = "ExchangeRatesPreferencesViewController"
    
    @IBOutlet private weak var baseCurrencyLabel: UILabel!
    @IBOutlet private weak var baseCurrencyPicker: UISegmentedControl!
    
    var context: Context?
    weak var delegate: ExchangeRatesPreferencesViewControllerDelegate?
    
    private let baseCurrencies = [BaseCurrency.usd, BaseCurrency.eur, BaseCurrency.rub, BaseCurrency.btc]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIItems()
    }
}

extension ExchangeRatesPreferencesViewController {
    func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: String.localized("ExchangeRatesPreferences.Save"), style: .plain, target: self, action: #selector(didTouchSaveBarButtonItem))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = String.localized("Shared.Preferences")
    }
    
    @objc func didTouchSaveBarButtonItem() {
        var newBaseCurrency: BaseCurrency?
        
        let currentlyBaseCurrencyIndex = baseCurrencies.index(of: context!.preferences.baseCurrency)!
        let selectedBaseCurrencyIndex = baseCurrencyPicker.selectedSegmentIndex
        if selectedBaseCurrencyIndex != currentlyBaseCurrencyIndex  {
            newBaseCurrency = baseCurrencies[selectedBaseCurrencyIndex]
        }
        
        delegate?.exchangeRatesViewControllerDidTouchSaveButton(sender: self, newBaseCurrency: newBaseCurrency)
    }
}

private extension ExchangeRatesPreferencesViewController {
    func setupUIItems() {
        setupNavigationBar()
        
        baseCurrencyLabel.text = String.localized("ExchangeRatesPreferences.BaseCurrencyLabel")
        baseCurrencyPicker.removeAllSegments()
        baseCurrencies.forEach { baseCurrency in
            baseCurrencyPicker.insertSegment(withTitle: baseCurrency.getCurrencySymbol(), at: baseCurrencyPicker.numberOfSegments, animated: false)
        }
        
        baseCurrencyPicker.selectedSegmentIndex = baseCurrencies.index(of: context!.preferences.baseCurrency)!
    }
}
