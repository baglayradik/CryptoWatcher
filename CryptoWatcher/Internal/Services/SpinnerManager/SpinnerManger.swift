import Foundation

protocol SpinnerManagerDelegate: AnyObject {
    func startSpinner()
    func stopSpinner()
}

class SpinnerManager {
    weak var delegate: SpinnerManagerDelegate?
    
    private var currentCount: Int = 0
    private var lock: NSLock = NSLock()
    
    func increaseCount(_ added: Int = 1) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        currentCount += added
        
        if currentCount == added {
            delegate?.startSpinner()
        }
    }
    
    func reduceCount(_ difference: Int = 1) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        currentCount -= difference
        assert(currentCount >= 0)
        
        if currentCount == 0 {
            delegate?.stopSpinner()
        }
    }
}

