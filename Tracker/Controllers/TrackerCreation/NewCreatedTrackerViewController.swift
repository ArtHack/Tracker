import UIKit
import SnapKit

protocol AddNewTrackerCategoryDelegate: AnyObject {
    func addNewTrackerCategory(_ category: TrackerCategory)
}

class NewCreatedTrackerViewController: UIViewController {
    
    var newCreatedTrackerType: TrackerType?
    var tableViewHeight: CGFloat?
    weak var delegate: AddNewTrackerCategoryDelegate?
    var trackerTitle = ""
    private var currentCategory: String? = "Category"
    var currrentSchedule: [Weekdays] = []
    
    private enum Section: Int, CaseIterable {
        case emojis
        case colors
    }
    
    let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪",
    ]
    
    let colors: [UIColor] = [
         UIColor.section1, UIColor.section2, UIColor.section3, UIColor.section4, UIColor.section5, UIColor.section6,
         UIColor.section7, UIColor.section8, UIColor.section9, UIColor.section10, UIColor.section11, UIColor.section12,
         UIColor.section13, UIColor.section14, UIColor.section15, UIColor.section16, UIColor.section17, UIColor.section18
    ]
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        switch newCreatedTrackerType {
        case .habitTracker:
            label.text = "Новая привычка"
        case .irregularEvent :
            label.text = "Новое нерегулярное событие"
        case .none:
            break
        }
        return label
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundNight
        let textFieldLeftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = textFieldLeftPaddingView
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "newCreatedTrackerCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackgroundNight
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let newCreatedTrackerCollectionView: UICollectionView = {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) ->
            NSCollectionLayoutSection? in
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1))
            
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(40),
                heightDimension: .absolute(40)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.1)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: 6)
            group.interItemSpacing = .fixed(12)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 17
            section.boundarySupplementaryItems = [headerElement]
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(NewCreatedTrackerCollectionViewCell.self, forCellWithReuseIdentifier: NewCreatedTrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(NewCreatedTrackerHeaderForCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: NewCreatedTrackerHeaderForCollectionView.reuseIdentifier)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
        
        private func setupDataSource() {
            dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
                collectionView: newCreatedTrackerCollectionView
            ) {
                (collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NewCreatedTrackerCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! NewCreatedTrackerCollectionViewCell
                
                switch indexPath.section {
                case Section.emojis.rawValue:
                    if let emoji = item as? String {
                        cell.emojiLabel.text = emoji
                        cell.emojiLabel.isHidden = false
                        cell.backgroundColor = .clear
                    }
                case Section.colors.rawValue:
                    if let color = item as? UIColor {
                        cell.backgroundColor = color
                        cell.layer.cornerRadius = 16
                        cell.layer.masksToBounds = true
                        cell.emojiLabel.isHidden = true
                    }
                default:
                    break
                }
                return cell
            }
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: NewCreatedTrackerHeaderForCollectionView.reuseIdentifier,
                for: indexPath) as? NewCreatedTrackerHeaderForCollectionView
            switch indexPath.section {
            case 0:
                view?.titleLabel.text = "Emoji"
            case 1:
                view?.titleLabel.text = "Colors"
            default:
                fatalError("Unknown section")
            }
            view?.titleLabel.font = .ysDisplayBold(size: 19)
            return view
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
            snapshot.appendSections([.emojis, .colors])
            snapshot.appendItems(emojis, toSection: .emojis)
            snapshot.appendItems(colors, toSection: .colors)
            dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    } ()
    
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypGray
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
//        setupDataSource()
        setupViews()
        setupConstraints()
        
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(newCreatedTrackerCollectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    func setupConstraints() {
        switch newCreatedTrackerType {
        case .habitTracker:
            tableViewHeight = 150
        case .irregularEvent:
            tableViewHeight = 75
        case .none: break
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.top).offset(40)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(75)
            make.width.equalTo(view.snp.width).offset(-32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(24)
            make.leading.equalTo(searchTextField.snp.leading)
            make.trailing.equalTo(searchTextField.snp.trailing)
            make.height.equalTo(tableViewHeight ?? CGFloat(0))
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(createButton.snp.leading).offset(-8)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        createButton.snp.makeConstraints { make in
            make.height.equalTo(cancelButton.snp.height)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.centerY.equalTo(cancelButton.snp.centerY)
            make.width.equalTo(cancelButton.snp.width)
        }
        
        newCreatedTrackerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(24)
            make.leading.equalTo(tableView.snp.leading)
            make.trailing.equalTo(tableView.snp.trailing)
            make.bottom.equalTo(cancelButton.snp.top)
        }
    }
    
    @objc private func createButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.addNewTrackerCategory(TrackerCategory(title: "CAtegory", trackers: [Tracker(id: UUID(), title: "Hello", color: .section1, emoji: "✅", schedule: self.currrentSchedule)]))
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func createButtonIsEnable() {
        if searchTextField.text?.isEmpty == false
            && ((currentCategory?.isEmpty) != nil)
        {
            createButton.backgroundColor = .ypBlackDay
            createButton.setTitleColor(.ypWhiteDay, for: .normal)
            createButton.isEnabled = true
        }
    }
}

//MARK: - UITableViewDelegate

extension NewCreatedTrackerViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            present(scheduleVC, animated: true)
        default:
            break
        }
    }
}

//MARK: - UITableViewDataSource

extension NewCreatedTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int
    ) -> Int {
        switch newCreatedTrackerType {
        case .habitTracker:
            return 2
        case .irregularEvent:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "newCreatedTarackerCell")
        cell.textLabel?.font = .ysDisplayMedium(size: 16)
        cell.detailTextLabel?.font = .ysDisplayMedium(size: 16)
        cell.textLabel?.textColor = .ypBlackDay
        cell.detailTextLabel?.textColor = .ypBlackDay
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
        case 1:
            cell.textLabel?.text = "Расписание"

        default:
            fatalError("Unknown row")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

//MARK: - UITextFieldDelegate

extension NewCreatedTrackerViewController: UITextFieldDelegate {
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        switch newCreatedTrackerType {
        case .habitTracker:
            if currrentSchedule.isEmpty == false {
                createButtonIsEnable()
                return true
            }
        case .irregularEvent:
            createButtonIsEnable()
            return true
        case .none:
            return true
        }
        return true
    }

    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if searchTextField.text?.isEmpty == true {
            createButton.backgroundColor = .ypBlackDay
            createButton.setTitleColor(.ypWhiteDay, for: .normal)
            createButton.isEnabled = false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        trackerTitle = textField.text ?? ""
        
        return true
    }
}

extension NewCreatedTrackerViewController: ScheduleViewControllerDelegate {
    func addNewSchedule(_ newSchedule: [Weekdays]) {
//        currrentSchedule = newSchedule
        createButtonIsEnable()
    }
}
