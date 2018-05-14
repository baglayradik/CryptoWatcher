import UIKit
import ScrollableGraphView

class DetailCurrencyViewController: UIViewController, Contextual {
    static let storyboardIdentifier = "DetailCurrencyViewController"
    private static var currencyCellReuseID = "ReusableCellID"
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var graphView: ScrollableGraphView!
    @IBOutlet weak var chageDisplaySegmentedControl: UISegmentedControl!
    
    var context: Context?
    var currencyInfo: CurrencyFullRaw?
    var currency: String?
    
    //    private
    private var numberOfItems = 30
    private  var plotOneData: [Double]?
    private var timesLabel:[Int] = []
    private var times:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = currency
        changeDisplayGraphView(chageDisplaySegmentedControl)
        
        //baseCurrencyPicker.insertSegment(withTitle: baseCurrency.getCurrencySymbol(), at: baseCurrencyPicker.numberOfSegments, animated: false)

        chageDisplaySegmentedControl.removeAllSegments()
        
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.Day"), at: 0, animated: false)
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.Week"), at: 1, animated: false)
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.Month"), at: 2, animated: false)
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.ThreeMonth"), at: 3, animated: false)
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.SixMonth"), at: 4, animated: false)
        chageDisplaySegmentedControl.insertSegment(withTitle: String.localized("Detail.Year"), at: 5, animated: false)
        chageDisplaySegmentedControl.selectedSegmentIndex = 0
    }
    
    
    @IBAction func changeDisplayGraphView(_ sender: UISegmentedControl) {
        switch  sender.selectedSegmentIndex {
        case 0:
            context?.currencyService.getHistoryOfHour(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "23", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (index,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        if index % 3  == 0 {
                            tmpPlotData.append(object.high!)
                            self.timesLabel.append(object.time!)
                        }
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .hour, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                case .failure(let error):
                    print(error)
                }
            })
        case 1:
            context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "7", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (_,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        tmpPlotData.append(object.high!)
                        self.timesLabel.append(object.time!)
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                    
                case .failure(let error):
                    print(error)
                }
            })
        case 2:
            context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "30", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (index,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        if index % 4  == 0 {
                            tmpPlotData.append(object.high!)
                            self.timesLabel.append(object.time!)
                        }
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                case .failure(let error):
                    print(error)
                }
            })
        case 3:
            context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "90", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (index,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        if index % 12  == 0 {
                            tmpPlotData.append(object.high!)
                            self.timesLabel.append(object.time!)
                        }
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                case .failure(let error):
                    print(error)
                }
            })
        case 4:
            context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "180", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (index,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        if index % 24  == 0 {
                            tmpPlotData.append(object.high!)
                            self.timesLabel.append(object.time!)
                        }
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                case .failure(let error):
                    print(error)
                }
            })
        case 5:
            context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: "360", completion: { (result) in
                switch result {
                case .success(let historyData):
                    var tmpPlotData:[Double] = []
                    self.plotOneData = []
                    self.timesLabel = []
                    self.times = []
                    for (index,object) in historyData.enumerated() {
                        guard self.timesLabel.count < 8 else  {
                            break
                        }
                        if index % 48  == 0 {
                            tmpPlotData.append(object.high!)
                            self.timesLabel.append(object.time!)
                        }
                    }
                    self.plotOneData = tmpPlotData
                    self.numberOfItems = tmpPlotData.count
                    self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                    self.graphView.dataSource = self
                    self.setupGraph(graphView: self.graphView)
                    self.graphView.reload()
                case .failure(let error):
                    print(error)
                }
            })
        default:
            break
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailTableViewController" {
            let detailTableViewController = segue.destination as? DetailTableViewController
            detailTableViewController?.context = context
            detailTableViewController?.currency = currency
        }
    }
}

extension DetailCurrencyViewController: ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        switch(plot.identifier) {
        case "currencyData":
            return plotOneData?[pointIndex] ?? 0
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return "\(self.times[pointIndex])"
    }
    
    func numberOfPoints() -> Int {
        return plotOneData?.count ?? 0
    }
    
    
    
    func setupGraph(graphView: ScrollableGraphView) {
        let linePlot = LinePlot(identifier: "currencyData")
        linePlot.lineColor = UIColor.clear
        linePlot.shouldFill = true
        linePlot.fillColor = UIColor.colorFromHex(hexString: "#FF0080")
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineThickness = 1
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        referenceLines.referenceLineLabelColor = UIColor.white
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        referenceLines.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        referenceLines.dataPointLabelColor = UIColor.white
        referenceLines.referenceLineNumberStyle = .decimal
        referenceLines.referenceLinePosition = .left
        referenceLines.referenceLineNumberOfDecimalPlaces = 2
        referenceLines.includeMinMax = true
        referenceLines.shouldShowReferenceLineUnits = true
        graphView.backgroundFillColor = UIColor.colorFromHex(hexString: "#222222")
        graphView.dataPointSpacing = 90
        graphView.topMargin = 50
        graphView.shouldAdaptRange = true
        graphView.leftmostPointPadding = 100
        graphView.addPlot(plot: linePlot)
        
        graphView.addReferenceLines(referenceLines: referenceLines)
    }
}

extension DetailCurrencyViewController {
    
//    enum FormatterType {
//        case day
//        case hour
//    }
//
//    func timeFormatter(type: FormatterType, times: [Int]) -> [String] {
//        let time = DateFormatter()
//        var tmpArray:[String] = []
//        switch type {
//        case .day:
//            time.dateFormat = "dd MMM"
//        case .hour:
//            time.dateFormat = "dd MMM, HH:mm"
//        }
//        for i in timesLabel {
//            let date = Date(timeIntervalSince1970: TimeInterval(i))
//            let stringTime = time.string(from: date)
//            tmpArray.append(stringTime)
//        }
//        return tmpArray
//    }
}

extension DetailCurrencyViewController {
    func createGraph(limit: String, indexData: Int? = nil) {
        context?.currencyService.getHistoryOfDay(coin: currency!, baseCurrency: (context?.preferences.baseCurrency)!.rawValue, limit: limit, completion: { (result) in
            switch result {
            case .success(let historyData):
                var tmpPlotData:[Double] = []
                self.plotOneData = []
                self.timesLabel = []
                self.times = []
                for (index,object) in historyData.enumerated() {
                    guard self.timesLabel.count < 8, let indexForPlot = indexData else  {
                        break
                    }
                    if index % indexForPlot  == 0 {
                        tmpPlotData.append(object.high!)
                        self.timesLabel.append(object.time!)
                    }
                }
                self.plotOneData = tmpPlotData
                self.numberOfItems = tmpPlotData.count
                self.times = Formatter.timeFormatter(type: .day, times: self.timesLabel)
                self.graphView.dataSource = self
                self.setupGraph(graphView: self.graphView)
                self.graphView.reload()
            case .failure(let error):
                print(error)
            }
        })
    }
}

