
import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<StoreUpdate.Move>?
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantConteiner.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.categoryTitle, ascending: true)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.fetchCategories(from: $0) })
        else { return [] }
        
        return categories
    }
    
    private func fetchCategories(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.categoryTitle else {
            throw StoreError.decodingErrorInvalidCategoryTitle
        }
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw StoreError.decodingErrorInvalidTrackers
        }
        
        return TrackerCategory(
            title: title,
            trackers: trackers.allObjects.compactMap { convert($0 as? TrackerCoreData) }
        )
    }
    
    private func convert(_ tracker: TrackerCoreData?) -> Tracker? {
        guard let tracker = tracker,
              let trackerId = tracker.trackerId,
              let trackerText = tracker.trackerName,
              let trackerEmoji = tracker.trackerEmoji,
              let trackerColorHex = tracker.trackerColor
        else { return nil }
        
        return Tracker(
            id: trackerId,
            title: trackerText,
            color: UIColor.color(from: trackerColorHex),
            emoji: trackerEmoji,
            schedule: WeekDaysMarshalling().convertStringToWeekDays(tracker.trackerSchedule)
        )
    }
    
    private func fetchCategory(with name: String) throws -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["categoryTitle", name])
        
        do {
            let category = try context.fetch(request).first
            return category
        } catch {
            throw StoreError.decodingErrorInvalidCategoryEntity
        }
    }
    
    func saveTracker(tracker: Tracker, to categoryName: String) throws {
        let trackerCoreData = try trackerStore.makeTracker(from: tracker)
        
        if let existingCategory = try? fetchCategory(with: categoryName),
           let existingTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] {
            
            var newCoreDataTrackers = existingTrackers
            newCoreDataTrackers.append(trackerCoreData)
            existingCategory.trackers = NSSet(array: newCoreDataTrackers)
            
            try context.save()
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
