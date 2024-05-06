import TabularData
import Foundation

let filePath = "/Users/agnesebussone/XcodeProjects/DeviceCGM/DeviceCGM/DeviceCGMOriginal.txt"

let options = CSVReadingOptions(hasHeaderRow: true, delimiter: "|")
guard let fileUrl = URL(string: filePath) else {
    fatalError("Error creating Url")
}

var covidDeathsDf = try! DataFrame(
    contentsOfCSVFile: fileUrl,
    options: options)

print("\(covidDeathsDf)")
