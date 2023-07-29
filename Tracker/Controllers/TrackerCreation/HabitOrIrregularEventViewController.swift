import UIKit
import SnapKit

protocol AddNewTrackerCategoryDelegate: AnyObject {
    func addNewTrackerCategory(_ category: TrackerCategory)
}

class HabitOrIrregularEventViewController: UIViewController {
    
    var newCreatedTrackerType: TrackerType?
    var tableViewHeight: CGFloat?
    var trackerTitle = ""
    var currrentSchedule: [Weekdays] = []
    weak var delegate: AddNewTrackerCategoryDelegate?

    private var currentCategory: String? = "Новая категория"
    private var emoji = ""
    private var color: UIColor = .clear
    
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
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackgroundNight
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return tableView
    }()
    
    private let emojiOrCollorCollectionView: UICollectionView = {
        
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
                heightDimension: .fractionalHeight(0.1)            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: 6)
            group.interItemSpacing = .fixed(22)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 15
            section.boundarySupplementaryItems = [headerElement]
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(HabitOrIrregularEventCollectionViewCell.self, forCellWithReuseIdentifier: HabitOrIrregularEventCollectionViewCell.reuseIdentifier)
        collectionView.register(HabitOrIrregularEventHeaderForCollectionView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HabitOrIrregularEventHeaderForCollectionView.reuseIdentifier)
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>! = nil
        
        private func setupDataSource() {
            dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
                collectionView: emojiOrCollorCollectionView
            ) {
                (collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HabitOrIrregularEventCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! HabitOrIrregularEventCollectionViewCell
                
                cell.backgroundColor = .clear
                cell.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
                cell.emojiOrColorLabel.isHidden = true
                
                switch indexPath.section {
                case Section.emojis.rawValue:
                    if let emoji = item as? String {
                        cell.emojiOrColorLabel.text = emoji
                        cell.emojiOrColorLabel.isHidden = false
                    }
                case Section.colors.rawValue:
                    if let color = item as? UIColor {
                        cell.backgroundColor = color
                        cell.layer.cornerRadius = 8
                        cell.layer.masksToBounds = true
                        cell.emojiOrColorLabel.isHidden = true
                        if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first, selectedIndexPath == indexPath {
                            cell.layer.borderWidth = 4
                            cell.layer.backgroundColor = color.cgColor
                        }
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
                withReuseIdentifier: HabitOrIrregularEventHeaderForCollectionView.reuseIdentifier,
                for: indexPath) as? HabitOrIrregularEventHeaderForCollectionView
            switch indexPath.section {
            case 0:
                view?.titleLabel.text = "Emoji"
            case 1:
                view?.titleLabel.text = "Colors"
            default:
                fatalError("Unknown section")
            }
            return view
        }
            emojiOrCollorCollectionView.allowsMultipleSelection = false
            emojiOrCollorCollectionView.delegate = self
        
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
        
        setupDataSource()
        setupViews()
        setupConstraints()
        
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        
        let subViews = [searchTextField, tableView, emojiOrCollorCollectionView, cancelButton, createButton ]
        subViews.forEach {
            scrollView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        switch newCreatedTrackerType {
        case .habitTracker:
            tableViewHeight = 150
        case .irregularEvent:
            tableViewHeight = 75
            tableView.separatorColor = .clear
        case .none: break
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.top).offset(40)
        }
        
        scrollView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-16)
            make.height.equalTo(75)
            make.width.equalTo(view.snp.width).offset(-32)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom).offset(24)
            make.leading.equalTo(searchTextField.snp.leading)
            make.trailing.equalTo(searchTextField.snp.trailing)
            make.height.equalTo(tableViewHeight ?? CGFloat(0))
        }
        
        emojiOrCollorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(24)
            make.leading.equalTo(scrollView.snp.leading).offset(16)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-16)
            make.height.equalTo(404)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(scrollView.snp.leading).offset(20)
            make.trailing.equalTo(scrollView.snp.centerX).offset(-4)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-34)
            make.height.equalTo(60)
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(emojiOrCollorCollectionView.snp.bottom)
            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
            make.leading.equalTo(scrollView.snp.centerX).offset(4)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-34)
            make.height.equalTo(cancelButton.snp.height)
        }
    }
    
    @objc private func createButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.addNewTrackerCategory(TrackerCategory(title: "Категория", trackers: [Tracker(id: UUID(), title: self.trackerTitle, color: self.color, emoji: self.emoji, schedule: self.currrentSchedule)]))
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

extension HabitOrIrregularEventViewController: UITableViewDelegate {
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

extension HabitOrIrregularEventViewController: UITableViewDataSource {
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
        let days = currrentSchedule.map { $0.shortLabel }
        let daysString = days.joined(separator: ", ")
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = currentCategory
        case 1:
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = daysString
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

extension HabitOrIrregularEventViewController: UITextFieldDelegate {
    
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
                trackerTitle = textField.text ?? ""
                return true
            }
        case .irregularEvent:
            createButtonIsEnable()
            trackerTitle = textField.text ?? ""
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
}

extension HabitOrIrregularEventViewController: ScheduleViewControllerDelegate {
    func addNewSchedule(_ newSchedule: [Weekdays]) {
        currrentSchedule = newSchedule
        tableView.reloadData()
        createButtonIsEnable()
    }
}

//MARK: - CollectionViewDelegate

extension HabitOrIrregularEventViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let cell = emojiOrCollorCollectionView.cellForItem(at: indexPath) as? HabitOrIrregularEventCollectionViewCell {
            switch indexPath.section {
            case 0:
                for item in 0..<emojiOrCollorCollectionView.numberOfItems(inSection: 0) {
                    guard let cell = emojiOrCollorCollectionView.cellForItem(at: IndexPath(row: item, section: 0))
                    else { return }
                    cell.backgroundColor = .clear
                }
                cell.backgroundColor = .ypGray
                emoji = cell.emojiOrColorLabel.text ?? "ramambahara"
                
            case 1:
                for item in 0..<emojiOrCollorCollectionView.numberOfItems(inSection: 1) {
                    guard let cell = emojiOrCollorCollectionView.cellForItem(at: IndexPath(row: item, section: 1)) else { return }
                    cell.layer.borderWidth = 0
                }
                cell.layer.borderColor = cell.contentView.backgroundColor?.withAlphaComponent(0.3).cgColor
                cell.layer.borderWidth = 3
                
                color = cell.backgroundColor ?? .red
                
            default:
                break
            }
        }
    }
}
