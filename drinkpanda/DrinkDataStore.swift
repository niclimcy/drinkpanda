import Foundation

class DrinkDataStore {
    static let shared = DrinkDataStore()

    private init() {}

    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        return documentsPath.appendingPathComponent("drinks.json")
    }

    func loadDrinks() -> [Drink] {
        guard let data = try? Data(contentsOf: fileURL),
              let drinks = try? JSONDecoder().decode([Drink].self, from: data) else {
            return []
        }
        return drinks
    }

    func saveDrinks(_ drinks: [Drink]) {
        do {
            let data = try JSONEncoder().encode(drinks)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save drinks: \(error)")
        }
    }
}