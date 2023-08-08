import UIKit
import SnapKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func plusButtonTapped(cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackerCollectionViewCell"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypRed
        return view
    }()
    
    private let numberOfDayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlackDay
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "0 Дней"
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 34 / 2
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.backgroundColor = .ypRed
        return button
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .ypBackgroundDay
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "Поливать растения"
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        addViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(tracker: Tracker) {
        nameLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        colorView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
    }
    
    func configRecord(countDays: Int, isDoneToday: Bool) {
        let title = isDoneToday ? "✓" : "+"
        plusButton.setTitle(title, for: .normal)
        
        let opacity: Float = isDoneToday ? 0.3 : 1
        plusButton.layer.opacity = opacity
        
        numberOfDayLabel.text = "\(countDays) Дней"
    }
    
    @objc private func plusButtonTapped() {
        delegate?.plusButtonTapped(cell: self)
    }
    
    private func addSubviews() {
        [colorView, numberOfDayLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [emojiLabel, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            colorView.addSubview($0)
        }
    }
    
    private func addViewConstraints() {
        let space: CGFloat = 12

        colorView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-42)
        }

        numberOfDayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(plusButton)
            make.leading.equalTo(contentView).offset(space)
        }

        plusButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-space)
            make.top.equalTo(colorView.snp.bottom).offset(8)
            make.height.equalTo(34)
            make.width.equalTo(34)
        }

        emojiLabel.snp.makeConstraints { make in
            make.leading.equalTo(colorView).offset(space)
            make.top.equalTo(colorView).offset(space)
            make.height.equalTo(24)
            make.width.equalTo(24)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(colorView).offset(space)
            make.trailing.equalTo(colorView).offset(-space)
            make.bottom.equalTo(colorView).offset(-space)
        }
    }
}
