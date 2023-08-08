import Foundation

enum Weekdays: String, Comparable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case suturday
    case sunday
    
    var cyrillic: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .suturday:
            return " Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
    
    var dayNumberOfWeek: Int {
        switch self {
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .suturday:
            return 7
        case .sunday:
            return 1
        }
    }
    
    var shortName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .suturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
    
    private var sortOrder: Int {
        switch self {
        case .monday:
            return 0
        case .tuesday:
            return 1
        case .wednesday:
            return 2
        case .thursday:
            return 3
        case .friday:
            return 4
        case .suturday:
            return 5
        case .sunday:
            return 6
        }
    }
    
    static func < (lhs: Weekdays, rhs: Weekdays) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
