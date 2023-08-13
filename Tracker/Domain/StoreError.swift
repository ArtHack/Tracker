import Foundation

enum StoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidText
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidColotHex
    case decodingErrorInvalidSchedule
    case decodingErrorInvalidCategoryTitle
    case decodingErrorInvalidTrackers
    case decodingErrorInvalidCategoryEntity
    case decodingErrorInvalidTrackerRecord
    case decodingErrorInvalidTracker
}
