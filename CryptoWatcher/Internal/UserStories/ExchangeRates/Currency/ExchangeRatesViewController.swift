import UIKit

class ExchangeRatesViewController: UIViewController, Contextual {
    static let storyboardIdentifier = "ExchangeRatesViewController"
    private static var currencyCellReuseID = "ReusableCellID"
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet private weak var coinNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var hoursLabel: UILabel!
    
    var context: Context?
    private var timer: Timer?
    var currencyInfo: CurrencyFullRaw?
    private let serialQueue = DispatchQueue(label: "serialQueue.DISK")
    private let spinnerManager = SpinnerManager()
    private var isFirstReloading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        coinNameLabel.text = String.localized("ExchangeRates.CoinName")
        priceLabel.text = String.localized("ExchangeRates.Price")
        hoursLabel.text = String.localized("ExchangeRates.Hours")
        
        context?.currencyService.addObserver(self)
        
        spinnerManager.delegate = self
        
        updatePrices()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updatePrices), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // to fix iOS 11.2 bug, when button remains faded after segue back
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        //
    }
}
//MARK:- UITableViewDataSource

extension ExchangeRatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return context!.currencyService.currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeRatesViewController.currencyCellReuseID, for: indexPath) as! CurrencyTableViewCell
        let coin = context!.currencyService.currencyList[indexPath.row]
        
        cell.context = context
        context?.currencyService.getCoinList(coin: coin.name, completion: { (result) in
            switch result {
            case .success(let coin):
                self.context!.imageService.getImage(imageUrl: coin.imageUrl!) { image in
                    if let image = image {
                        cell.iconCurrencyImage.image = image
                    }
                }
                cell.fullNameLabel?.text = coin.fullName
                cell.nameLabel?.text = coin.symbol
            case .failure(let error):
                self.showError(error: error)
            }
        })
        context?.currencyService.coinInfo(coin: (context?.currencyService.currencyList[indexPath.row].name)!, completion: { (result) in
            switch result {
            case .success(let infoCoin):
                
                cell.priceLabel?.text = "\(NumberFormatter.formatDecimal(number: infoCoin.price)) \(self.context!.preferences.baseCurrency.getCurrencySymbol())"
                cell.priceLabel.textColor = self.getNumberColor(number: infoCoin.changePct24Hour)
                cell.changePriceLabel.text = "\(Double.roundToPlaces(places: infoCoin.changePct24Hour)) %"
                cell.changePriceLabel.textColor = self.getNumberColor(number: infoCoin.changePct24Hour)
            case .failure(let error):
                self.showError(error: error)
            }
        })
        
        context?.currencyService.denotifyWhenCoinPriceChange(observer: cell)
        context?.currencyService.notifyWhenCoinPriceChange(observer: cell, coin: context!.preferences.trackedCoins[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: String.localized("ExchangeRates.Delete")) { _, indexPath in
            guard let coinName = self.context?.currencyService.currencyList[indexPath.row].name else {
                return
            }
            try! self.context?.currencyService.removeTrackedCoin(removingCoin: coinName)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


extension ExchangeRatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = DetailCurrencyViewController.storyboardIdentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let detailCurrencyViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! DetailCurrencyViewController
        
        detailCurrencyViewController.currency = context!.currencyService.currencyList[indexPath.row].name
        detailCurrencyViewController.context = context
        detailCurrencyViewController.currencyInfo = currencyInfo
        
        navigationController?.pushViewController(detailCurrencyViewController, animated: true)
    }
}

extension ExchangeRatesViewController {
    private func setupNavigationBar() {
        let preferencesButton = UIBarButtonItem(title: String.localized("Shared.Preferences"), style: .plain, target: self, action: #selector(didTouchPreferencesBarButtonItem))
        let addCurrencyButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTouchNewCurrencyBarButtonItem))
        
        navigationItem.leftBarButtonItem = preferencesButton
        navigationItem.rightBarButtonItem = addCurrencyButton
    }
    
    @objc func didTouchPreferencesBarButtonItem() {
        let identifier = ExchangeRatesPreferencesViewController.storyboardIdentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let exchangeRatesPreferencesViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! ExchangeRatesPreferencesViewController
        
        exchangeRatesPreferencesViewController.context = context
        exchangeRatesPreferencesViewController.delegate = self
        
        navigationController?.pushViewController(exchangeRatesPreferencesViewController, animated: true)
    }
    
    @objc func didTouchNewCurrencyBarButtonItem() {
        let identifier = NewCurrencyViewController.storyboardIdentifier
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.main)
        let newCurrencyViewController = storyboard.instantiateViewController(withIdentifier: identifier) as! NewCurrencyViewController
        
        newCurrencyViewController.context = context
        newCurrencyViewController.delegate = self
        
        navigationController?.pushViewController(newCurrencyViewController, animated: true)
    }
}

extension ExchangeRatesViewController: ExchangeRatesPreferencesViewControllerDelegate {
    func exchangeRatesViewControllerDidTouchSaveButton(sender: ExchangeRatesPreferencesViewController, newBaseCurrency: BaseCurrency?) {
        if let baseCurrency = newBaseCurrency {
            context?.preferences.baseCurrency = baseCurrency
            spinnerManager.increaseCount()
            context?.currencyService.updatePrices(completion: { (result) in
                defer {
                    self.spinnerManager.reduceCount()
                }
                switch result {
                case .success(_):
                    print("All data are fetched")
                case .failure(let error):
                    self.showError(error: error)
                }
            })
        }
        navigationController?.popViewController(animated: true)
    }
}

extension ExchangeRatesViewController: NewCurrencyViewControllerDelegate {
    func newCurrencyViewControllerDidTouchSaveButton(sender: NewCurrencyViewController, _ newCurrency: String) {
        spinnerManager.increaseCount()
        context?.currencyService.convertFullnameToShortname(fullname: newCurrency) { result in
            defer {
                self.spinnerManager.reduceCount()
            }
            do {
                switch result {
                case .success(let currencyName):
                    try self.context?.currencyService.addTrackedCoin(newCoin: currencyName)
                    self.updatePrices()
                case .failure(let error):
                    throw error
                }
            }
            catch {
                self.showError(error: error)
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

extension ExchangeRatesViewController: CurrencyServiceObserver {
    func onTrackedCoinsUpdate(coins: [String]) {
        spinnerManager.increaseCount()
        context?.currencyService.updatePrices(completion: { (_) in
            self.spinnerManager.reduceCount()
        })
    }
}

private extension ExchangeRatesViewController {
    @objc func updatePrices() {
        self.context?.currencyService.updatePrices(completion: { (result) in
            switch result {
            case .success(let res):
                if self.isFirstReloading {
                    self.tableView.reloadData()
                    self.isFirstReloading = false
                }
                print("All data are fetched, currency count = \(res.count)")
            case .failure(let error):
                self.showError(error: error)
            }
        })
    }
}

private extension ExchangeRatesViewController {
    func showError(error: Error){
        let errorAllert = UIAlertController(title: String.localized("ExchangeRates.Alert.title"), message: " \(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: String.localized("ExchangeRates.Alert.okButton"), style: .cancel, handler: nil)
        errorAllert.addAction(okAction)
        present(errorAllert, animated: true, completion: nil)
    }
    
    func getNumberColor(number: Double) -> UIColor {
        if number == 0 {
            return UIColor.gray
        }
        if number < 0 {
            return UIColor.red
        }
        else {
            return UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
        }
    }
}

extension ExchangeRatesViewController: SpinnerManagerDelegate {
    func startSpinner() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    func stopSpinner() {
        tableView.reloadData()
        loadingIndicator.stopAnimating()
        tableView.isHidden = false
    }
}

