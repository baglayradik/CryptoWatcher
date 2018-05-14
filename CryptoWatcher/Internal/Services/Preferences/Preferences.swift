import Foundation

protocol PreferencesObserver: AnyObject {
    func onBaseCurrencyChange(newBaseCurrency: BaseCurrency)
    func onTrackedCoinsUpdate(coins: [String])
}

enum PreferencesError: Error {
    case DoubleTrackedCoin
    case RemovingNonExistedCoin
}

class Preferences {
    private static var baseCurrencyKey = "baseCurrency"
    private static var trackedCoinsKey = "trackedCoins"
    private var observers: [PreferencesObserver] = []
  
    
    var baseCurrency: BaseCurrency {
        get {
            let value = UserDefaults.standard.string(forKey: Preferences.baseCurrencyKey)
            guard let rawValue = value, let baseCurrency = BaseCurrency(rawValue: rawValue) else {
                return .usd
            }
            return baseCurrency
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Preferences.baseCurrencyKey)
            
            for observer in observers {
                observer.onBaseCurrencyChange(newBaseCurrency: newValue)
            }
        }
    }
    
    var trackedCoins: [String] {
        get {
            let value = UserDefaults.standard.array(forKey: Preferences.trackedCoinsKey) as? [String]
          //  let value = UserDefaults.standard.string(forKey: Preferences.trackedCoinsKey)
            guard let coins = value else {
                return ["BTC","ETH","XEM"]
            }
            return coins
          //  return coins.components(separatedBy: " ")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Preferences.trackedCoinsKey)
            for observer in observers {
                observer.onTrackedCoinsUpdate(coins: newValue)
            }
        }
    }
    
    func addTrackedCoin(newCoin: String) throws {
        var currentlyTracked = trackedCoins
        if currentlyTracked.index(of: newCoin) != nil {
            throw PreferencesError.DoubleTrackedCoin
        }
        currentlyTracked.append(newCoin)
        trackedCoins = currentlyTracked
    }
    
    func removeTrackedCoin(removingCoin: String) throws {
        var currentlyTracked = trackedCoins
        let indexOfRemovingCoin = currentlyTracked.index(of: removingCoin)
        guard let index = indexOfRemovingCoin else {
            throw PreferencesError.RemovingNonExistedCoin
        }
        currentlyTracked.remove(at: index)
        trackedCoins = currentlyTracked
    }
}

extension Preferences {
    func addObserver(_ observer: PreferencesObserver) {
        assert(observers.index{$0 === observer} == nil)
        observers.append(observer)
    }
    
    func removeObserver(_ observer: PreferencesObserver) {
        let observerIndex = observers.index{$0 === observer}
        assert(observerIndex != nil)
        observers.remove(at: observerIndex!)
    }
}
