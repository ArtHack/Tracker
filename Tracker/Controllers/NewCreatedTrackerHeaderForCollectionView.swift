import UIKit
import SnapKit

class NewCreatedTrackerHeaderForCollectionView: UICollectionReusableView {
    
    static let reuseIdentifier = "HeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .ysDisplayMedium(size: 19)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setupViews() {
        addSubview(titleLabel)
    }
    
    func setupConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(28)
            $0.bottom.equalToSuperview()
        }
    }
}
