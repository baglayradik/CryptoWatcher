import UIKit

class ConverterViewController: UIViewController, Contextual {
    static let storyboardIdentifier = "ConverterViewController"
    static let delimeter = String.localized("Shared.DecimalDelimeter")
    
    @IBOutlet private weak var firstCurrencyPicker: UITextField!
    @IBOutlet private weak var firstCurrencyField: UITextField!
    
    @IBOutlet private weak var secondCurrencyPicker: UITextField!
    @IBOutlet private weak var secondCurrencyField: UITextField!
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    var context: Context?
    private var spinnerManager: SpinnerManager?
    
    private var autocompleteList: [String] = []
    private var isEditedFirstPicker: Bool = true
    private var isEditedFirstField: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerManager = SpinnerManager()
        spinnerManager?.delegate = self
        
        setupUIItems()
    }
}

extension ConverterViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == firstCurrencyPicker {
            isEditedFirstPicker = true
        }
        if textField == secondCurrencyPicker {
            isEditedFirstPicker = false
        }
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            var newString = (textFieldToChange.text ?? "")
            newString.replaceSubrange(Range<String.Index>(range, in: newString)!, with: string)
        
        if textFieldToChange == firstCurrencyField || textFieldToChange == secondCurrencyField {
            let allowedCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ConverterViewController.delimeter.first!]
            if !allowedCharacters.isSuperset(of: newString) {
                return false
            }

            var isReplaceZero = false
            if textFieldToChange.text ?? "0" == "0" {
                if string != ConverterViewController.delimeter {
                    textFieldToChange.text = string //"09" -> "9"
                    newString = string
                    isReplaceZero = true
                }
            }
            
            if newString.isEmpty {
                if textFieldToChange == firstCurrencyField {
                    secondCurrencyField.text = ""
                }
                else {
                    firstCurrencyField.text = ""
                }
                return true
            }
            
            if validateStringIsDecimal(newString) {
                if newString.last ?? " " == ConverterViewController.delimeter.first! {
                    newString = String(newString.dropLast())
                }
            
                let valueWrapped = Double(newString.replacingOccurrences(of: String.localized("Shared.DecimalDelimeter"), with: "."))
                switch valueWrapped {
                case .some(let value):
                    tryConvert(value: value, fromFirstCurrency: textFieldToChange == firstCurrencyField)
                    fallthrough
                case .none:
                    if !isReplaceZero {
                        isEditedFirstField = textFieldToChange == firstCurrencyField
                    }
                    return !isReplaceZero
                }
            }
            else {
                return false
            }
        }
        if textFieldToChange == firstCurrencyPicker || textFieldToChange == secondCurrencyPicker {
            newString = newString.lowercased()

            var i = 0
            while autocompleteList[i].lowercased() < newString {
                i += 1
                if i == autocompleteList.count {
                    i = 0
                    break
                }
            }
            
            var picker: UICollectionView?
            if textFieldToChange == firstCurrencyPicker {
                picker = firstCurrencyPicker.inputAccessoryView! as? UICollectionView
            }
            if textFieldToChange == secondCurrencyPicker {
                picker = secondCurrencyPicker.inputAccessoryView! as? UICollectionView
            }
            
            picker!.scrollToItem(at: IndexPath.init(row: i, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally , animated: true)
            return true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let currencyField = isEditedFirstField ? firstCurrencyField : secondCurrencyField
        if textField == firstCurrencyPicker {
            guard let text = currencyField!.text, let value = Double(text) else {
                return true
            }
            tryConvert(value: value, fromFirstCurrency: isEditedFirstField)
        }
        if textField == secondCurrencyPicker {
            guard let text = currencyField!.text, let value = Double(text) else {
                return true
            }
            tryConvert(value: value, fromFirstCurrency: isEditedFirstField)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == firstCurrencyPicker || textField == secondCurrencyPicker {
            guard let coinName = textField.text else {
                return
            }
            
            if autocompleteList.contains(coinName) {
                textField.layer.borderWidth = 0
                
                let currencyField = isEditedFirstField ? firstCurrencyField : secondCurrencyField
                if textField == firstCurrencyPicker {
                    guard let text = currencyField!.text, let value = Double(text) else {
                        return
                    }
                    tryConvert(value: value, fromFirstCurrency: isEditedFirstField)
                }
                if textField == secondCurrencyPicker {
                    guard let text = currencyField!.text, let value = Double(text) else {
                        return
                    }
                    tryConvert(value: value, fromFirstCurrency: isEditedFirstField)
                }
            }
            else {
                textField.layer.borderWidth = 0.5
            }
        }
    }
    
    private func tryConvert(value: Double, fromFirstCurrency: Bool) {
        guard let firstCurrency = firstCurrencyPicker.text, let secondCurrency = secondCurrencyPicker.text else {
            return
        }
        
        if fromFirstCurrency && firstCurrencyField.text == "" {
            secondCurrencyField.text = ""
        }
        
        if !fromFirstCurrency && secondCurrencyField.text == "" {
            firstCurrencyField.text = ""
        }
        
        if autocompleteList.contains(firstCurrency) && autocompleteList.contains(secondCurrency) {
            context?.currencyService.convertFullnameToShortname(fullname: firstCurrency) { result in
                switch result {
                case .success(let firstCurrency):
                    self.context?.currencyService.convertFullnameToShortname(fullname: secondCurrency) { result in
                        switch result {
                        case .success(let secondCurrency):
                            var textFieldToOutput: UITextField
                            var baseCurrency: String
                            var targetCurrency: String
                            
                            if fromFirstCurrency {
                                textFieldToOutput = self.secondCurrencyField
                                baseCurrency = secondCurrency
                                targetCurrency = firstCurrency
                            }
                            else {
                                textFieldToOutput = self.firstCurrencyField
                                baseCurrency = firstCurrency
                                targetCurrency = secondCurrency
                            }
                            
                            self.context?.currencyService.getCoinPrice(coin: targetCurrency, baseCurrency: baseCurrency) { result in
                                switch result {
                                case .success(let price):
                                    textFieldToOutput.text = (value * price).toString()
                                case .failure(let error):
                                    self.showError()
                                    print(error)
                                    break
                                }
                            }
                        case .failure(let error):
                            print(error)
                            break
                        }
                    }
                case .failure(let error):
                    print(error)
                    break
                }
            }

        }
    }
    
    func showError() {
        let errorAllert = UIAlertController(title: String.localized("Converter.Alert.Title"), message: String.localized("Converter.Alert.Message"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: String.localized("Converter.Alert.OkButton"), style: .cancel, handler: nil)
        errorAllert.addAction(okAction)
        present(errorAllert, animated: true, completion: nil)
    }
}

private extension ConverterViewController {
    func validateStringIsDecimal(_ string: String) -> Bool {
        if (string.reduce(0){$0 + ($1 == ConverterViewController.delimeter.first! ? 1: 0)}) > 1 {
            return false
        }
        
        if (string.first ?? "0") == ConverterViewController.delimeter.first! {
            return false
        }
        
        if !string.starts(with: "0\(ConverterViewController.delimeter.first!)") && string.hasPrefix("0") {
            return string == "0"
        }
        
        return true
    }
}

private extension ConverterViewController {
    func setupUIItems() {
        spinner.center = view.center
        
        navigationItem.title = String.localized("Converter.Title")
    
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 40)
        layout.scrollDirection = .horizontal
        let autocompleteCollection = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40), collectionViewLayout: layout)
        autocompleteCollection.register(AutocompleteCollectionCell.self, forCellWithReuseIdentifier: ConverterViewController.collectionCellReuseID)
        
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
        
        firstCurrencyPicker.placeholder = String.localized("Converter.FirstCurrencyField.Placeholder")
        secondCurrencyPicker.placeholder = String.localized("Converter.SecondCurrencyField.Placeholder")
        
        firstCurrencyPicker.inputAccessoryView = autocompleteCollection
        secondCurrencyPicker.inputAccessoryView = autocompleteCollection
        
        firstCurrencyPicker.delegate = self
        secondCurrencyPicker.delegate = self
        
        setupTextFieldLayer(firstCurrencyPicker)
        setupTextFieldLayer(secondCurrencyPicker)
    }
    
    func setupTextFieldLayer(_ textField: UITextField) {
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = false
        textField.layer.borderColor = UIColor.red.cgColor
    }
}

extension ConverterViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    private static let collectionCellReuseID = "collectionReusableCellID"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return autocompleteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConverterViewController.collectionCellReuseID, for: indexPath) as! AutocompleteCollectionCell
        
        cell.label.text = autocompleteList[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditedFirstPicker {
            firstCurrencyPicker.text = autocompleteList[indexPath.row]
        }
        else {
            secondCurrencyPicker.text = autocompleteList[indexPath.row]
        }
    }
}

extension ConverterViewController: SpinnerManagerDelegate {
    func startSpinner() {
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}
