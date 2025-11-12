// calendar/Records/RecurrenceRuleRecords.swift

import EventKit
import Foundation

struct RecurrenceRule {
    var frequency: String
    var interval: Int?
    var endDate: String? // Or Double? if you need numeric timestamps
    var occurrence: Int?
    var daysOfTheWeek: [DaysOfTheWeek]?
    var daysOfTheMonth: [Int]?
    var monthsOfTheYear: [MonthOfTheYear]?
    var weeksOfTheYear: [Int]?
    var daysOfTheYear: [Int]?
    var setPositions: [Int]?
}

struct DaysOfTheWeek {
    var dayOfTheWeek: DayOfTheWeek = .sunday
    var weekNumber: Int
}

enum MonthOfTheYear: Int {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
}

enum DayOfTheWeek: Int {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    func toEKType() -> EKWeekday {
        switch self {
        case .monday: return .monday
        case .tuesday: return .tuesday
        case .wednesday: return .wednesday
        case .thursday: return .thursday
        case .friday: return .friday
        case .saturday: return .saturday
        case .sunday: return .sunday
        }
    }
}
