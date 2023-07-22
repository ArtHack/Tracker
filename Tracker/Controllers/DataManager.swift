import Foundation

class DataManager {
    static let shared = DataManager()

    var catigories: [TrackerCategory] = [
    TrackerCategory(title: "Sport",
                    trackers: [
                        Tracker(
                            id: UUID(),
                            title: "Running",
                            color: .section2,
                            emoji: "🏃‍♂️",
                            schedule: [Weekdays.monday, Weekdays.tuesday, Weekdays.wednesday, Weekdays.thursday, Weekdays.friday, Weekdays.saturday]
                        ),
                        Tracker(
                            id: UUID(),
                            title: "Workout",
                            color: .section2,
                            emoji: "🏋️‍♂️",
                            schedule: [Weekdays.monday, Weekdays.tuesday, Weekdays.wednesday, Weekdays.thursday, Weekdays.friday, Weekdays.saturday]
                        )
                    ]
                ),


        TrackerCategory(title: "Musik",
                        trackers: [
                            Tracker(
                                id: UUID(),
                                title: "Play Guitar",
                                color: .section1,
                                emoji: "🎸",
                                schedule: [Weekdays.friday, Weekdays.monday]
                            ),
                        ]
                    ),
                ]
}

    
