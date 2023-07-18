import UIKit
import SnapKit

class TrackersViewController: UIViewController {
    
    var dateManager = DataManager.shared
    
    let nctvs = NewCreatedTrackerViewController()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var currentDate: Date?
    private var completedTrackers: Set<TrackerRecord> = []
    private var searchText = ""
    private var tmpDate: TrackerCategory?
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.calendar.firstWeekday = 2
        return datePicker
    }()
    
    private lazy var searchBar: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    private lazy var trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        collection.register(
            TrackerHeaderForCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderForCollectionView.identifier
        )
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    private lazy var placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SearchError")
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .ysDisplayMedium(size: 12)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBar()
        setupViews()
        setupConstraints()
        setupPlaceholeder()
    }
    
    private func setBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBar
    }
    
    private func setupPlaceholeder() {
        trackerCollectionView.isHidden = categories.isEmpty
        placeholderLabel.isHidden = !categories.isEmpty
        placeholderView.isHidden = !categories.isEmpty
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderView.image = UIImage(named: "Placeholder")
    }
    private func setupViews() {
        view.addSubview(placeholderView)
        view.addSubview(placeholderLabel)
        view.addSubview(trackerCollectionView)
        view.backgroundColor = .white
    }
    
    private func setupConstraints() {
        placeholderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
            $0.height.equalTo(80)
        }

        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        trackerCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
//        self.dismiss(animated: true)
        reloadVisibleCategories()
    }

    @objc private func addTracker() {
        let typeOfNewTrackerVC = NewCreatedTrackerTypeViewController(categories: categories)
        typeOfNewTrackerVC.delegate = self
        present(typeOfNewTrackerVC, animated: true)
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    private func reloadVisibleCategories() {
        var filterCategory = categories.map { filterCategoryByDate(category: $0 )}
        filterCategory = filterCategory.filter { !$0.trackers.isEmpty }
        if filterCategory.isEmpty {
            if searchText.isEmpty {
                placeholderLabel.text = "Ничего не найдено"
                placeholderView.image = UIImage(named: "SearchError")
            }
        }
        visibleCategories = filterCategory
        trackerCollectionView.reloadData()
    }
    
    func filterCategoryByDate(category: TrackerCategory) -> TrackerCategory {
        let tracker = category.trackers.filter( {($0.title.contains(searchText) || searchText.isEmpty) && ($0.schedule.contains(where: {$0.dayIndex == currentDate?.dayIndex() }))})
        let filterCategory = TrackerCategory(title: category.title, trackers: tracker)
        return filterCategory
    }
}
//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        collectionView.isHidden = visibleCategories.count == 0
        return visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let trackers = visibleCategories[section].trackers
        return trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = trackerCollectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isCompletedToday = completedTrackers.contains(where: { $0.id == tracker.id})
        let completedDays = completedTrackers.filter {$0.id == tracker.id}.count
        cell.delegate = self
        cell.configure(tracker: tracker)
        cell.configRecord(completedDays: completedDays, isCompletedToday: isCompletedToday)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeaderForCollectionView.identifier, for: indexPath) as? TrackerHeaderForCollectionView else {
            return UICollectionReusableView()
        }
        view.setTitle(visibleCategories[indexPath.section].title)
        
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.frame.width - 9 - 2 * 16) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(
            width:collectionView.frame.width,
            height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
         16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
         9
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        reloadVisibleCategories()
    }
}

// MARK: - Delegate

extension TrackersViewController: NewCreatedTrackerTypeDelegate {
    func addNewTrackerCategory(_ category: TrackerCategory) {
        dismiss(animated: true)
        var trackerCategory = category
        currentDate = datePicker.date
        if trackerCategory.trackers[0].schedule.isEmpty {
            guard let numberDay = currentDate?.dayIndex() else { return }
            var currentDay = numberDay
            if numberDay == 1 {
                currentDay = 8
            }
            let newSchedule = Weekdays.allCases[currentDay - 2]
            let oldTracker = trackerCategory.trackers[0]
            let updateTracker = Tracker(id: oldTracker.id, title: oldTracker.title, color: oldTracker.color, emoji: oldTracker.emoji, schedule: oldTracker.schedule + [newSchedule])
            var updatedTrackers = trackerCategory.trackers
            updatedTrackers[0] = updateTracker
            let updatedCategory = TrackerCategory(title: trackerCategory.title, trackers: updatedTrackers)
            trackerCategory = updatedCategory
        }
        
        if categories.contains(where: { $0.title == trackerCategory.title}) {
            guard let index = categories.firstIndex(where: { $0.title == trackerCategory.title }) else { return }
            let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers + trackerCategory.trackers
            let updatedTrackerByСategory = TrackerCategory(title: trackerCategory.title, trackers: updatedTrackers)
            
            categories[index] = updatedTrackerByСategory
        } else {
            categories.append(trackerCategory)
        }
        trackerCollectionView.reloadData()
        reloadVisibleCategories()
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func plusButtonTaped(cell: TrackerCell) {
        let indexPath: IndexPath = trackerCollectionView.indexPath(for: cell) ?? IndexPath()
        let id = visibleCategories[indexPath.section].trackers[indexPath.row].id
        var daysCount = completedTrackers.filter { $0.id == id }.count
        guard let currentDate = currentDate else { return }
            if !completedTrackers.contains(where: { $0.id == id && $0.date == currentDate}) {
                completedTrackers.insert(TrackerRecord(id: id, date: currentDate ))
                daysCount += 1
                cell.configRecord(completedDays: daysCount, isCompletedToday: true)
        } else {
            completedTrackers.remove(TrackerRecord(id: id, date: currentDate ))
            daysCount -= 1
            cell.configRecord(completedDays: daysCount, isCompletedToday: false)
        }
    }
}
