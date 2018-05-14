import UIKit

protocol NewCurrencyViewControllerDelegate: AnyObject {
    func newCurrencyViewControllerDidTouchSaveButton(sender: NewCurrencyViewController, _ newCurrency: String)
}

enum ValidatingNewCurrencyErrors {
    case Ok
    case DoubleTrackedCoin
    case NonExistedCoin
}

class NewCurrencyViewController: UIViewController, Contextual {
    static let storyboardIdentifier = "NewCurrencyViewController"

    @IBOutlet private weak var pickCurrencyLabel: UILabel!
    
    @IBOutlet private weak var currencyNameTextField: UITextField!
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    var context: Context?
    weak var delegate: NewCurrencyViewControllerDelegate?
    private var autocompleteList: [String] = []
    private var spinnerManager: SpinnerManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerManager = SpinnerManager()
        spinnerManager?.delegate = self
        
        setupUIItems()
    }
}

extension NewCurrencyViewController {
    func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: String.localized("ExchangeRatesPreferences.Save"), style: .plain, target: self, action: #selector(didTouchSaveBarButtonItem))
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = String.localized("NewCurrency.Title")
    }
    
    @objc func didTouchSaveBarButtonItem() {
        guard let currencyName = currencyNameTextField.text else {
            return
        }
        
        switch validateNewCurrency(currencyName) {
        case .Ok:
            break
        case .NonExistedCoin:
            currencyNameTextField.layer.borderWidth = 0.5
            return
        case .DoubleTrackedCoin:
            let errorAllert = UIAlertController(title: String.localized("NewCurrency.DoubleTrackedCoinError.Title"), message: String.localized("NewCurrency.DoubleTrackedCoinError.Description"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: String.localized("NewCurrency.DoubleTrackedCoinError.OkButton"), style: .cancel, handler: nil)
            errorAllert.addAction(okAction)
            present(errorAllert, animated: true, completion: nil)
            return
        }
        
        delegate?.newCurrencyViewControllerDidTouchSaveButton(sender: self, currencyName)
    }
}

private extension NewCurrencyViewController {
    func setupUIItems() {
        setupNavigationBar()
        
        spinner.center = view.center
        pickCurrencyLabel.text = String.localized("NewCurrency.PickCurrencyLabel")
        
        currencyNameTextField.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .horizontal
        let autocompleteCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40), collectionViewLayout: layout)
        autocompleteCollection.register(AutocompleteCollectionCell.self, forCellWithReuseIdentifier: NewCurrencyViewController.collectionCellReuseID)
        
        autocompleteCollection.dataSource = self
        autocompleteCollection.delegate = self
        autocompleteCollection.backgroundColor = UIColor.white
        
        spinnerManager?.increaseCount()
        context!.currencyService.getAviableCoins { result in
            defer {
                self.spinnerManager?.reduceCount()
            }
            switch result {
            case .success(let list):
                self.autocompleteList = list
            case .failure(let error):
                print(error)
            }
        }
        currencyNameTextField.inputAccessoryView = autocompleteCollection
        setupTextFieldLayer(currencyNameTextField)
    }
}

extension NewCurrencyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private static let collectionCellReuseID = "collectionReusableCellID"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return autocompleteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewCurrencyViewController.collectionCellReuseID, for: indexPath) as! AutocompleteCollectionCell
        
        cell.label.text = autocompleteList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currencyNameTextField.text = autocompleteList[indexPath.row]
    }
}

extension NewCurrencyViewController: UITextFieldDelegate {
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = (textFieldToChange.text ?? "")
        newString.replaceSubrange(Range<String.Index>(range, in: newString)!, with: string)
        newString = newString.lowercased()
        
        var i = 0
        while autocompleteList[i].lowercased() < newString {
            i += 1
        }
        
        let picker = currencyNameTextField.inputAccessoryView! as! UICollectionView
        picker.scrollToItem(at: IndexPath.init(row: i, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally , animated: true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let currencyName = textField.text else {
            return
        }
        
        if validateNewCurrency(currencyName) == .Ok {
            textField.layer.borderWidth = 0
        }
        else {
            textField.layer.borderWidth = 0.5
        }
    }
}

extension NewCurrencyViewController: SpinnerManagerDelegate {
    func startSpinner() {
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

private extension NewCurrencyViewController {
    func validateNewCurrency(_ coinName: String) -> ValidatingNewCurrencyErrors {
        if autocompleteList.contains(coinName) {
            if let shortName = try? context!.currencyService.convertFullnameToShortNameFromCache(fullname: coinName) {
                if context!.preferences.trackedCoins.contains(shortName) {
                    return .DoubleTrackedCoin
                }
                else {
                    return .Ok
                }
            }
        }
        
        return .NonExistedCoin
    }
    
    func setupTextFieldLayer(_ textField: UITextField) {
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        textField.layer.borderColor = UIColor.red.cgColor
    }
}
