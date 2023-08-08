import Foundation

final class ScheduleMarshalling {
    func convertWeekDayToString(_ day: [Weekdays]) -> String {
        let schedule = day.map { $0.rawValue + " "}.joined()
        return schedule
    }
    
    func convertStringToWeekDay(_ string: String?) -> [Weekdays] {
        guard let scheduleString = string?.components(separatedBy: [" "]) else { return [] }
        let schedule = scheduleString.compactMap { Weekdays(rawValue: $0) }
        return schedule
    }
}
