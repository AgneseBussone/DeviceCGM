//

import Foundation
import TabularData

public class CGMDataFrame: CGMAnalysis {
    private let fileURL: URL
    private var dataFrame: DataFrame? = nil
    
    // Columns to be read from the file
    private let ptId = ColumnID("PtID", Int.self)
    private let deviceTime = ColumnID("DeviceDtTm", String.self)
    private let recordType = ColumnID("RecordType", String.self)
    private let cgmValue = ColumnID("Value", Double.self)
    
    private let readingOptions = CSVReadingOptions(hasHeaderRow: true, delimiter: "|")
    
    private let formattingOptions = FormattingOptions(
        maximumLineWidth: 250,
        maximumCellWidth: 30,
        maximumRowCount: 5
    )

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    public func getMinMaxMedian(for patientId: PatiendId, during timeInterval: DateInterval?) -> PatientMinMaxMedian? {
        ensureDataFrame()
        
        let patientData = getFilteredPatientData(for: patientId, during: timeInterval)
        
        if let patientSummary = patientData?.summary(of: cgmValue.name),
           let max = patientSummary[SummaryColumnIDs.maximum.name, Double.self][0],
           let min = patientSummary[SummaryColumnIDs.minimum.name, Double.self][0],
           let median = patientSummary[SummaryColumnIDs.median.name, Double.self][0]
        {
//            print(patientSummary.description(options: formattingOptions))
            return PatientMinMaxMedian(min: min, max: max, median: median)
            
        } else {
            return nil
        }
    }
    
    public func getHypoEventsCount(for patientId: PatiendId, during timeInterval: DateInterval?) -> Int {
        ensureDataFrame()
        let patientData = getOrderedMeasurements(for: patientId, during: timeInterval)
        return countHypoEvents(patientData)
    }
    
    public func getOrderedMeasurements(for patientId: PatiendId, during timeInterval: DateInterval?) -> [PatientMeasurement] {
        ensureDataFrame()
        
        let patientData = getFilteredPatientData(for: patientId, during: timeInterval)
        
        if var patientData = patientData {
            if timeInterval == nil {
                // in this case deviceTime has not been converted to Date
                patientData = transformDeviceTimeInDate(patientData)
            }
            patientData.sort(on: deviceTime.name, Date.self, order: .ascending)
            let measures = patientData.selecting(columnNames: [deviceTime.name, cgmValue.name])
            
            return measures.rows.map { row in
                PatientMeasurement(timestamp: row[0] as! Date, cgm: row[1] as! Double)}
        }
        
        return []
    }
    
    private func getFilteredPatientData(for patientId: PatiendId, during timeInterval: DateInterval?) -> DataFrame? {
        var patientData = DataFrame(dataFrame!
            .filter(on: ptId) { $0 == patientId }
        )

        if patientData.isEmpty { return nil }
        
        patientData = purgeCalibration(patientData)
        
        if let timeInterval = timeInterval {
            patientData = filterByTimeInterval(patientData, interval: timeInterval)
        }
        
        if patientData.isEmpty { return nil }
        
        return patientData.selecting(columnNames: [deviceTime.name, cgmValue.name])
    }
    
    private func filterByTimeInterval(_ data: DataFrame, interval: DateInterval) -> DataFrame {
        let filteredData = transformDeviceTimeInDate(data)
        return DataFrame(filteredData.filter(on: deviceTime.name, Date.self, { interval.contains($0!) }))
    }
    
    private func purgeCalibration(_ data: DataFrame) -> DataFrame {
        var purgedData = data
        purgedData.transformColumn(recordType) { (type: String) -> Bool in
            type == "CGM"
        }
        return DataFrame(purgedData.filter(on: recordType.name, Bool.self, { $0! }))
    }
    
    private func transformDeviceTimeInDate(_ data: DataFrame) -> DataFrame {
        var transformedData = data
        transformedData.transformColumn(deviceTime) { (dateStr: String) -> Date in
            try! dateParseStrategy.parse(dateStr)
        }
        return transformedData
    }

    private func ensureDataFrame() {
        if dataFrame == nil {
            readData()
        }
    }
    
    internal func readData() {
        let (columnNames, columnTypes) = columnSetup()
        
        // read the file
        let data =  try! DataFrame(
            contentsOfCSVFile: fileURL,
            columns: columnNames,
            types: columnTypes,
            options: readingOptions)
            
        dataFrame = data
        
//        print(dataFrame!.description(options: formattingOptions))
    }
    
    private func columnSetup() -> (columnNames: [String], columnTypes: [String : CSVType]) {
        // Read only the coloumns that we're interested in
        let columnNames = [ptId.name, deviceTime.name, recordType.name, cgmValue.name]
        
        // Specify types for the data in the columns
        let columnTypes: [String : CSVType] = [
            ptId.name: .integer,
            deviceTime.name: .string,
            recordType.name: .string,
            cgmValue.name: .double]
        
        return (columnNames, columnTypes)
    }
}

extension CGMDataFrame {
    // This is just for performance comparisons: here it'll transform the Dates while reading the file
    internal func readDataWithDateParsing() {
        let columnNames = [ptId.name, deviceTime.name, recordType.name, cgmValue.name]
        
        // Specify types for the data in the columns
        let columnTypes: [String : CSVType] = [
            ptId.name: .integer,
            deviceTime.name: .date,
            recordType.name: .string,
            cgmValue.name: .double]
        
        var readingOptions = CSVReadingOptions(hasHeaderRow: true, delimiter: "|")
        readingOptions.addDateParseStrategy(dateParseStrategy)
        
        // read the file
        _ = try! DataFrame(
            contentsOfCSVFile: fileURL,
            columns: columnNames,
            types: columnTypes,
            options: readingOptions)
    }
}
