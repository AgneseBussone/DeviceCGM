//

import XCTest
@testable import DeviceCGM

final class CGMAnalysisTests: XCTestCase {

//    Avg. time: 54 sec
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: timeInterval): 0.41
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: nil): 0.18
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: timeInterval): 0.42
//    Total number of measurments for patient 39 = 109918
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: nil): 5.67
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: timeInterval): 0.42
//    Hypo count for patient 39 = 50
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: nil): 5.66
    func test_dictionary_streamReader() {
        let db = CGMDictionary(fileURL: realFileURL())
        db.readDataWithStreamReader()
        allMethods(db)
    }

//    Avg. time: 42 sec
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: timeInterval): 0.41
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: nil): 0.17
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: timeInterval): 0.41
//    Total number of measurments for patient 39 = 109918
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: nil): 5.66
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: timeInterval): 0.41
//    Hypo count for patient 39 = 50
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: nil): 5.64
    func test_dictionary2_lineReader() {
        let db = CGMDictionary(fileURL: realFileURL())
        db.readDataWithLineReader()
        allMethods(db)
    }

//     Avg. time: 22.5 sec
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: timeInterval): 2.93
//    ⏱️ Execution time for getMinMaxMedian(for: ptId, during: nil): 2.50
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: timeInterval): 2.93
//    Total number of measurments for patient 39 = 109918
//    ⏱️ Execution time for getOrderedMeasurements(for: ptId, during: nil): 3.19
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: timeInterval): 2.92
//    Hypo count for patient 39 = 50
//    ⏱️ Execution time for getHypoEventsCount(for: ptId, during: nil): 3.20
    func test_dataframe() {
        let db = CGMDataFrame(fileURL: realFileURL())
        db.readData()
        allMethods(db)
    }

    func allMethods(_ db: CGMAnalysis) {
        let ptId = 39
        var timeInterval = DateInterval(start: createDate("2000-03-25 00:02:56")!, end: createDate("2000-03-25 02:22:56")!)
        
        // MARK: - Min-max-median
        
        var start = Date()
        var minMaxMedian = db.getMinMaxMedian(for: ptId, during: timeInterval)
        var end = Date()
        XCTAssertNotNil(minMaxMedian)
        XCTAssertEqual(minMaxMedian?.min, 88)
        XCTAssertEqual(minMaxMedian?.max, 136)
        XCTAssertEqual(minMaxMedian?.median, 116)
        print("⏱️ Execution time for getMinMaxMedian(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))")

        start = Date()
        minMaxMedian = db.getMinMaxMedian(for: ptId, during: nil)
        end = Date()
        XCTAssertNotNil(minMaxMedian)
        print("⏱️ Execution time for getMinMaxMedian(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))")

        // MARK: - Ordered measures
        
        timeInterval = DateInterval(start: createDate("2000-04-21 04:31:56")!, end: createDate("2000-04-21 05:16:56")!)
        start = Date()
        var measures = db.getOrderedMeasurements(for: ptId, during: timeInterval)
        end = Date()
        XCTAssertFalse(measures.isEmpty)
        XCTAssertEqual(measures.count, 10)
        print("⏱️ Execution time for getOrderedMeasurements(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))")
        
        // Get all measurments
        start = Date()
        measures = db.getOrderedMeasurements(for: ptId, during: nil)
        end = Date()
        XCTAssertFalse(measures.isEmpty)
        print("Total number of measurments for patient \(ptId) = \(measures.count)") // -> 109918
        print("⏱️ Execution time for getOrderedMeasurements(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))")

        
        // MARK: - Hypo Events
        
        timeInterval = DateInterval(start: createDate("2000-04-21 17:00:00")!, end: createDate("2000-04-21 18:00:00")!)
        
        start = Date()
        var hypoEvents = db.getHypoEventsCount(for: ptId, during: timeInterval)
        end = Date()
        XCTAssertEqual(hypoEvents, 1)
        print("⏱️ Execution time for getHypoEventsCount(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))")
        start = Date()
        hypoEvents = db.getHypoEventsCount(for: ptId, during: nil)
        end = Date()
        print("Hypo count for patient \(ptId) = \(hypoEvents)") // -> 50
        print("⏱️ Execution time for getHypoEventsCount(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))")
    }
    
    // Avg: 41 sec. Memory usage constantly increases to ~ 1.2GB
    func test_dictionaryReadingPerformance_streamReader() {
        let start = Date()
        CGMDictionary(fileURL: realFileURL()).readDataWithStreamReader()
        let end = Date()
        print("⏱️ Execution time: \(String(format: "%.2f", end.timeIntervalSince(start)))")
    }

    // Avg: 30 sec. Memory usage constantly increases to ~ 760MB
    func test_dictionaryReadingPerformance_lineReader() {
        let start = Date()
        CGMDictionary(fileURL: realFileURL()).readDataWithLineReader()
        let end = Date()
        print("⏱️ Execution time: \(String(format: "%.2f", end.timeIntervalSince(start)))")
    }
    
    // Avg: 3.651 sec. Memory usage peaks at 1.5GB for a short instant
    func test_readingPerformance() {
        self.measure {
            CGMDataFrame(fileURL: realFileURL()).readData()
        }
    }

    // Avg: 34.165 sec
    func test_readingWithDateParsingPerformance() {
        self.measure {
            CGMDataFrame(fileURL: realFileURL()).readDataWithDateParsing()
        }
    }
    
    private func realFileURL() -> URL {
        let bundle = Bundle(for: CGMDictionary.self)
        return bundle.url(forResource: "DeviceCGMUtf8", withExtension: "txt")!
    }
    
    private func createDate(_ d: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: d)
    }

}
