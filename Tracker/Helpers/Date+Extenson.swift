import Foundation

extension Date {
    func dayIndex() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
