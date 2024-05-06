//

import XCTest
import TabularData
@testable import DeviceCGM

final class CGMDataFrameTests: XCTestCase {

    // Avg. 21 sec
    func test() {
        let db = CGMDataFrame(fileURL: realFileURL())
        let ptId = 39
        var timeInterval = DateInterval(start: createDate("2000-03-25 00:02:56")!, end: createDate("2000-03-25 02:22:56")!)
        
        // read the data before measuring the execution of the methods -> avg 3.5 sec
        db.readData()
        
        // MARK: - Min-max-median
        
        var start = Date()
        var minMaxMedian = db.getMinMaxMedian(for: ptId, during: timeInterval)
        var end = Date()
        XCTAssertNotNil(minMaxMedian)
        XCTAssertEqual(minMaxMedian?.min, 88)
        XCTAssertEqual(minMaxMedian?.max, 136)
        XCTAssertEqual(minMaxMedian?.median, 116)
        print("⏱️ Execution time for getMinMaxMedian(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 2.94 sec

        start = Date()
        minMaxMedian = db.getMinMaxMedian(for: ptId, during: nil)
        end = Date()
        XCTAssertNotNil(minMaxMedian)
        print("⏱️ Execution time for getMinMaxMedian(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 2.50 sec

        // MARK: - Ordered measures
        
        timeInterval = DateInterval(start: createDate("2000-04-21 04:31:56")!, end: createDate("2000-04-21 05:16:56")!)
        start = Date()
        var measures = db.getOrderedMeasurements(for: ptId, during: timeInterval)
        end = Date()
        XCTAssertFalse(measures.isEmpty)
        XCTAssertEqual(measures.count, 10)
        print("⏱️ Execution time for getOrderedMeasurements(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 2.93 sec
        
        // Get all measurments
        start = Date()
        measures = db.getOrderedMeasurements(for: ptId, during: nil)
        end = Date()
        XCTAssertFalse(measures.isEmpty)
        print("Total number of measurments for patient \(ptId) = \(measures.count)") // -> 109918
        print("⏱️ Execution time for getOrderedMeasurements(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 3.18 sec

        
        // MARK: - Hypo Events
        
        timeInterval = DateInterval(start: createDate("2000-04-21 17:00:00")!, end: createDate("2000-04-21 18:00:00")!)
        
        start = Date()
        var hypoEvents = db.getHypoEventsCount(for: ptId, during: timeInterval)
        end = Date()
        XCTAssertEqual(hypoEvents, 1)
        print("⏱️ Execution time for getHypoEventsCount(for: ptId, during: timeInterval): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 2.94 sec

        start = Date()
        hypoEvents = db.getHypoEventsCount(for: ptId, during: nil)
        end = Date()
        print("Hypo count for patient \(ptId) = \(hypoEvents)") // -> 50
        print("⏱️ Execution time for getHypoEventsCount(for: ptId, during: nil): \(String(format: "%.2f", end.timeIntervalSince(start)))") // -> 3.20 sec
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
        let bundle = Bundle(for: CGMDataFrame.self)
        return bundle.url(forResource: "DeviceCGMUtf8", withExtension: "txt")!
    }

}
