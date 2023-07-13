import UIKit
import SnapKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    weak var delegate: TrackerCellDelegate?
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .section1
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 24)
        label.backgroundColor = .ypBackgroundNight
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhiteDay
        label.text = " "
        label.font = .ysDisplayMedium(size: 12)
        return label
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .ysDisplayMedium(size: 12)
        label.textColor = .ypBlackDay
        label.text = " "
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func plusButtonTapped() {
        guard let trackerId = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    func setupViews() {
        contentView.addSubview(cellView)
        cellView.addSubview(emojiLabel)
        cellView.addSubview(titleLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(daysCounterLabel)

    }
    
    func setupConstraints() {
        
        cellView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-42)
        }
        
        plusButton.snp.makeConstraints {
            $0.top.equalTo(cellView.snp.bottom).offset(16)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-12)
            $0.width.equalTo(34)
            $0.height.equalTo(34)
        }
        
        daysCounterLabel.snp.makeConstraints {
            $0.centerY.equalTo(plusButton.snp.centerY)
            $0.leading.equalTo(contentView.snp.leading).offset(12)
        }
        
        emojiLabel.snp.makeConstraints {
            $0.top.equalTo(cellView).offset(12)
            $0.leading.equalTo(cellView).offset(12)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(cellView).offset(12)
            $0.bottom.equalTo(cellView).offset(-12)
            $0.trailing.equalTo(cellView).offset(-12)
        }
    }

    func configure(
        for cell: UICollectionViewCell,
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        self.plusButton.backgroundColor = tracker.color
         
        setupViews()
        setupConstraints()
        
        cellView.backgroundColor = tracker.color
        daysCounterLabel.text = "\(completedDays) days"
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        
        let title = isCompletedToday ? "✓" : "+"
        plusButton.setTitle(title, for: .normal)
    }
}
