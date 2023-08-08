import UIKit
import SnapKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func addNewTrackerCategory(_ newTrackerCategory: TrackerCategory)
}

final class NewTrackerViewController: UIViewController {
    weak var delegate: NewTrackerViewControllerDelegate?
    var typeOfNewTracker: TrackerType?
    private var heightTableView: CGFloat = 74
    private var currentCategory: String? = "Новая категория"
    private var trackerText = ""
    private var schedule: [Weekdays] = []
    private var emoji = ""
    private var color: UIColor = .clear
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlackDay
        switch typeOfNewTracker {
        case .habitTracker: label.text = "Новая привычка"
        case .irregularEvent: label.text = "Новое нерегулярное событие"
        case .none: break
        }
        return label
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .white
        
        return scroll
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.clearButtonMode = .whileEditing
        let leftInsetView = UIView(frame: CGRect(x: 0, y: 0, width: 17, height: 30))
        textField.leftView = leftInsetView
        textField.leftViewMode = .always
        textField.backgroundColor = .ypBackgroundDay
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .ypBackgroundDay
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .ypGray
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .white
        return collection
    }()
    
    private let emojiAndColorsCollection = EmojiAndColorsCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        addSubviews()
        addConstraints()
        setupCollection()
    }
    
    func setupCollection() {
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.register(EmojiAndColorsCollectionCell.self, forCellWithReuseIdentifier: EmojiAndColorsCollectionCell.reuseIdentifier)
        
        collectionView.delegate = emojiAndColorsCollection
        collectionView.dataSource = emojiAndColorsCollection
        emojiAndColorsCollection.delegate = self
    }
    
    func addSubviews() {
        [titleLabel, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [textField, tableView, collectionView, saveButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
    }
    
    func addConstraints() {
        switch typeOfNewTracker {
        case .habitTracker: heightTableView = 149
        case .irregularEvent: heightTableView = 74
        case .none: break
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }

        scrollView.snp.makeConstraints { make in
            make.width.equalTo(view)
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.bottom.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.leading.equalTo(scrollView).offset(16)
            make.trailing.equalTo(scrollView).offset(-16)
            make.height.equalTo(75)
            make.width.equalTo(view).offset(-32)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(24)
            make.leading.equalTo(textField)
            make.trailing.equalTo(textField)
            make.height.equalTo(heightTableView)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(32)
            make.leading.equalTo(scrollView)
            make.trailing.equalTo(scrollView)
            make.height.equalTo(484)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(scrollView).offset(20)
            make.trailing.equalTo(scrollView.snp.centerX).offset(-4)
            make.bottom.equalTo(scrollView).offset(-34)
            make.height.equalTo(60)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.trailing.equalTo(scrollView).offset(-20)
            make.leading.equalTo(scrollView.snp.centerX).offset(4)
            make.bottom.equalTo(scrollView).offset(-34)
            make.height.equalTo(60)
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) {
        }
    }
    
    @objc private func createButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.addNewTrackerCategory(TrackerCategory(title: "Новая категория", trackers: [Tracker(id: UUID(), title: self.trackerText, color: self.color, emoji: self.emoji, schedule: self.schedule)]))
        }
    }
    
    private func buttonIsEnabled() {
        guard let text = textField.text, let currentCategory else { return }
        if !text.isEmpty && !currentCategory.isEmpty {
            saveButton.backgroundColor = .black
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.isEnabled = true
        }
    }
}

//MARK: -UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeOfNewTracker {
        case .habitTracker: return 2
        case .irregularEvent: return 1
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .ypGray
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = currentCategory
        case 1:
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = scheduleToString(for: schedule)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    private func scheduleToString(for: [Weekdays]) -> String {
        guard schedule.count != Weekdays.allCases.count else { return "Каждый день" }

        let scheduleSorted = schedule.sorted()
        let scheduleShortName = scheduleSorted.map { $0.shortName }.joined(separator: ", ")
        return scheduleShortName
    }
}
//MARK: -UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            present(scheduleVC, animated: true)
        default: break
        }
    }
}
//MARK: - UITextFieldDelegate
extension NewTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        
        switch typeOfNewTracker {
        case .habitTracker:
            trackerText = textField.text ?? ""
            if !schedule.isEmpty {
                buttonIsEnabled()
                return true
            }
        case .irregularEvent:
            buttonIsEnabled()
            trackerText = textField.text ?? ""
            return true
        case .none:
            return true
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textField = textField.text else { return }
        if textField.isEmpty == true {
            saveButton.backgroundColor = .ypBlackDay
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.isEnabled = false
        }
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func addNewSchedule(_ newSchedule: [Weekdays]) {
        schedule = newSchedule
        tableView.reloadData()
        buttonIsEnabled()
    }
}

extension NewTrackerViewController: EmojiAndColorsCollectionDelegate {
    func addNewEmoji(_ emoji: String) {
        self.emoji = emoji
    }
    
    func addNewColor(_ color: UIColor) {
        self.color = color
    }
}
