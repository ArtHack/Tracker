import UIKit
import SnapKit

class HabitOrIrregularEventCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "newCreatedTarackerCell"
        
    var emojiOrColorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiOrColorLabel)
        emojiOrColorLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
