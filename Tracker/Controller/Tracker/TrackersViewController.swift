import UIKit
import SnapKit

class TrackersViewController: UIViewController {
    
    var dataManager = DataManager.shared
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var currentDate = Date()
    private var completedTrackers: [TrackerRecord] = []

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()

    private lazy var searchBar: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
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
        imageView.image = UIImage(named: "Placeholder")
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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
        reloadData()
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
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday , from: datePicker.date)
        let filterText = (searchBar.searchBar.text ?? "").lowercased()
        
        visibleCategories = categories.compactMap { catigory in
                let trackers = catigory.trackers.filter { tracker in
                    let textCondition = filterText.isEmpty ||
                    tracker.title.lowercased().contains(filterText)
                    let dateCondition = tracker.timetable?.contains { weekDay in
                        weekDay.dayIndex == filterWeekday
                    } == true
                    return dateCondition
                }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                title: catigory.title,
                trackers: trackers
            )
        }
        reloadPlaceholder()
        trackerCollectionView.reloadData()
    }
    
    private func reloadData() {
        categories = dataManager.catigories
        dateChanged()
    }
    
    private func reloadPlaceholder() {
        placeholderView.isHidden = !categories.isEmpty
        placeholderLabel.isHidden = !categories.isEmpty
        trackerCollectionView.isHidden = categories.isEmpty
    }

}
//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
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
            for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]

        cell.delegate = self

        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter {
            $0.id == tracker.id
        }.count
        cell.configure(
            for: cell,
            with: tracker,
            isCompletedToday: isCompletedToday,
            completedDays: completedDays,
            indexPath: indexPath)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeaderForCollectionView.identifier, for: indexPath) as? TrackerHeaderForCollectionView else {
            return UICollectionReusableView()
        }
        let titleCategory = visibleCategories[indexPath.section].title
        view.configure(header: titleCategory)
        
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
        return 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 9
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    
    func completeTracker(id: UUID, at indexPath: IndexPath)  {
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        
        trackerCollectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
        trackerCollectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate

extension TrackersViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != nil {
            reloadVisibleCategories()
        }
    }
}

extension TrackersViewController: NewCreatedTrackerTypeDelegate {
    func addNewTrackerCategory(_ category: TrackerCategory) {
        dismiss(animated: true)
        var category = category
        if ((category.trackers[0].timetable?.isEmpty) != nil) {
            guard let weekDay = currentDate.dayIndex() else { return }
            var currentDay = weekDay
            if weekDay == 1 {
                currentDay = 8
            }
            let timetable = Weekdays.allCases[currentDay - 1]
            category.trackers[0].timetable?.append(timetable)
        }
        if categories.contains(where: { $0.title == category.title}) {
            guard let index = categories.firstIndex(where: {$0.title == category.title})
            else { return }
        
        let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers + category.trackers
            let updatedTrackerByСategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
            
            categories[index] = updatedTrackerByСategory
        } else {
            categories.append(category)
        }
        reloadVisibleCategories()
        trackerCollectionView.reloadData()
    }
}

