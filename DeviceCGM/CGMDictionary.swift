//

import Foundation

public class CGMDictionary: CGMAnalysis {
    private let txtFileURL: URL
    
    private enum RecordType {
        case CGM
        case Calibration
    }
    
    private struct Record {
        let timestamp: String
        let recordType: RecordType
        let value: Double
        
        func date() -> Date {
            try! dateParseStrategy.parse(timestamp)
        }
    }
    
    private var db: [PatiendId: [Record]] = [:]
    
    public init(fileURL: URL) {
        self.txtFileURL = fileURL
    }
    
    public func getMinMaxMedian(for patientId: PatiendId, during interval: DateInterval? = nil) -> PatientMinMaxMedian? {
        ensureDb()
        if let patientData = db[patientId] {
            
            let values = patientData
                .filter { $0.recordType == .CGM && interval?.contains($0.date()) ?? true }
                .map { $0.value }
                .sorted()
            
            if values.isEmpty {
                return nil
            }

            // calculate the median for values
            let count = values.count
            let median: Double
            if count % 2 == 0 {
                median = (values[count / 2 - 1] + values[count / 2]) / 2
            } else {
                median = values[count / 2]
            }
            
            return PatientMinMaxMedian(min: values.min()!, max: values.max()!, median: median)
        }
        
        return nil
    }
    
    public func getOrderedMeasurements(for patientId: PatiendId, during interval: DateInterval? = nil) -> [PatientMeasurement] {
        ensureDb()
        if let patientData = db[patientId] {
            return patientData
                .filter { $0.recordType == .CGM && interval?.contains($0.date()) ?? true }
                .sorted { $0.date() < $1.date() }
                .map { PatientMeasurement(timestamp: $0.date(), cgm: $0.value) }
        }
        
        return []
    }
    
    public func getHypoEventsCount(for patientId: PatiendId, during interval: DateInterval? = nil) -> Int {
        ensureDb()
        let patientData = getOrderedMeasurements(for: patientId, during: interval)
        return countHypoEvents(patientData)
    }
    
    private func ensureDb() {
        if db.isEmpty {
            readData()
        }
    }
    
    internal func readData() {
        if let reader = LineReader(path: txtFileURL.path()) {
            
            for line in reader {
                if line.isEmpty {
                    continue
                }
                
                let (ptId, record) = readRecordLine(line)
                if ptId > -1 {
                    if db[ptId] == nil {
                        db[ptId] = []
                    }
                    db[ptId]?.append(record!)
                }
            }
        }
    }
    
    private func readRecordLine(_ line: String) -> (PatiendId, Record?) {
        let elements = line.components(separatedBy: "|")
        // RecID|PtID|ParentCITYDeviceUploadsID|DeviceDtTm|RecordType|Value|Units|SortOrd
        
        guard elements.count == 8 else {
            return (-1, .none)
        }

        guard let ptId = Int(elements[1]) else {
            return (-1, .none)
        }
                
        let recordType = elements[4] == "CGM" ? RecordType.CGM : RecordType.Calibration
        
        guard let value = Double(elements[5]) else {
            return (-1, .none)
        }
        
        return (ptId, Record(
            timestamp: elements[3],
            recordType: recordType,
            value: value
        ))
    }
}
