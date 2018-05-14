import UIKit

class AutocompleteCollectionCell: UICollectionViewCell {
    var label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)

        addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
