import Foundation

final class WeekDaysMarshalling {
    func convertWeekDaysToString(_ days: [Weekdays]) -> String {
        let schedule = days.map { $0.rawValue + " " }.joined()
        return schedule
    }
    
    func convertStringToWeekDays(_ string: String?) -> [Weekdays] {
        guard let scheduleStringArray = string?.components(separatedBy: [" "]) else { return [] }
        let scheduleArray = scheduleStringArray.compactMap { Weekdays(rawValue: $0) }
        return scheduleArray
    }
}
