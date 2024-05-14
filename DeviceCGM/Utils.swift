//

import Foundation

let dateParseStrategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits):\(second: .twoDigits)", timeZone: TimeZone(secondsFromGMT: 0)!)


func countHypoEvents(_ patientData: [PatientMeasurement]) -> Int {
    if !patientData.isEmpty {
        var hypoEvents = 0
        var start: Date? = nil
        var end: Date? = nil
        patientData.forEach {
            if $0.cgm < 70 {
                if start == nil {
                    start = $0.timestamp
                } else {
                    end = $0.timestamp
                }
            } else {
                if let s = start, let e = end, isAtLeastFifteenMinutesApart(s, e) {
                    hypoEvents += 1
                }
                start = nil
                end = nil
            }
        }
        return hypoEvents
    }
    
    return 0
}


private func isAtLeastFifteenMinutesApart(_ date1: Date, _ date2: Date) -> Bool {
    let difference = abs(date2.timeIntervalSince(date1))
    return difference >= 15 * 60
}
