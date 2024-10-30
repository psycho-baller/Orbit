import Foundation

struct DataLoader {
    static func loadAreaDataFromJSON() -> [Area] {
        guard let url = Bundle.main.url(forResource: "AreaData", withExtension: "json") else {
            print("AreaData.json file not found.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let areas = try decoder.decode([Area].self, from: data)
            return areas
        } catch {
            print("Error loading AreaData.json: \(error.localizedDescription)")
            return []
        }
    }
}
