// calendar/Records/AlarmRecords.swift

struct Alarm {
    var absoluteDate: String?
    var relativeOffset: Int?
    var structuredLocation: AlarmLocation?
    var method: String?
}

struct AlarmLocation {
    var title: String
    var proximity: String?
    var radius: Double?
    var coords: Coordinates?
}

struct Coordinates {
    var latitude: Double
    var longitude: Double
}
