//

import Foundation

public typealias PatiendId = Int

public struct PatientMinMaxMedian {
    public let min: Int
    public let max: Int
    public let median: Double
}

public struct PatientMeasurement {
    public let timestamp: Date
    public let cgm: Int
}

public protocol CGMAnalysis {
    
    // if the given interval is nil, it'll consider all record for the given patient
    
    func getMinMaxMedian(for: PatiendId, during: DateInterval?) -> PatientMinMaxMedian?
    func getHypoEventsCount(for: PatiendId, during: DateInterval?) -> Int
    func getOrderedMeasurements(for: PatiendId, during: DateInterval?) -> [PatientMeasurement]
}
