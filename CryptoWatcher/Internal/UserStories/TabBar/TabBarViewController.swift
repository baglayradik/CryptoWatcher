import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, Contextual {
    var context: Context?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = Context.createContext()
        setupBarItems(context: context!)
    }
}

private extension TabBarViewController {
    func setupBarItems(context: Context) {
        let exchangeRatesIdentifier = ExchangeRatesViewController.storyboardIdentifier
        let exchangeRatesStoryboard = UIStoryboard(name: exchangeRatesIdentifier, bundle: nil)
        let exchangeRatesController = exchangeRatesStoryboard.instantiateViewController(withIdentifier: exchangeRatesIdentifier) as! ExchangeRatesViewController
        exchangeRatesController.context = context
        
        let exchangeRatesNavigationContoller = UINavigationController()
        exchangeRatesNavigationContoller.viewControllers = [exchangeRatesController]
        
        let converterIdentifier = ConverterViewController.storyboardIdentifier
        let converterStoryboard = UIStoryboard(name: converterIdentifier, bundle: nil)
        let converterController = converterStoryboard.instantiateViewController(withIdentifier: converterIdentifier) as! ConverterViewController
        converterController.context = context
        
        let converterNavigationController = UINavigationController()
        converterNavigationController.viewControllers = [converterController]
        
        let exchangeRatesBarItem = UITabBarItem(title: String.localized("TabBar.ExchangeRates"), image: #imageLiteral(resourceName: "exchangeRatesTabBarIcon"), selectedImage: #imageLiteral(resourceName: "exchangeRatesTabBarIconFilled"))
        let converterBarItem = UITabBarItem(title: String.localized("TabBar.Converter"), image: #imageLiteral(resourceName: "converterTabBarIcon"), selectedImage: #imageLiteral(resourceName: "converterTabBarIconFilled"))
        
        exchangeRatesNavigationContoller.tabBarItem = exchangeRatesBarItem
        converterNavigationController.tabBarItem = converterBarItem
        
        self.viewControllers = [exchangeRatesNavigationContoller, converterNavigationController]
    }
}
