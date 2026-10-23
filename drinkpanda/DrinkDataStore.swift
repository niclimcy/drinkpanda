import UIKit

class DrinkDataStore {
    static let shared = DrinkDataStore()
    
    private(set) var drinks: [Drink] = []
    
    private init() {
        drinks = loadDrinks()
    }
    
    
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var fileURL: URL {
        documentsURL.appendingPathComponent("drinks.json")
    }
    
    private func loadDrinks() -> [Drink] {
        guard let data = try? Data(contentsOf: fileURL),
              var drinks = try? JSONDecoder().decode([Drink].self, from: data) else { return []}
        for index in drinks.indices {
            drinks[index].image = loadImage(for: drinks[index].id)
        }
        return drinks
    }
    
    private func saveDrinks(_ drinks: [Drink]) {
        do {
            let data = try JSONEncoder().encode(drinks)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save drinks: \(error)")
        }
    }
    
    func addDrink(_ drink: Drink) {
        saveImage(drink.image, for: drink.id)
        drinks.append(drink)
        saveDrinks(drinks)
    }
    
    func updateDrink(_ drink: Drink) {
        guard let index = drinks.firstIndex(where: {$0.id == drink.id}) else { return }
        if drinks[index].image !== drink.image {
            saveImage(drink.image, for: drink.id)
        }
        drinks[index] = drink
        saveDrinks(drinks)
    }
    
    func deleteDrink(_ drink: Drink) {
        guard let index = drinks.firstIndex(where: {$0.id == drink.id}) else { return }
        deleteDrink(at: index)
    }
    
    func deleteDrink(at index: Int) {
        deleteImage(for: drinks[index].id)
        drinks.remove(at: index)
        saveDrinks(drinks)
    }
    
    private func imageURL(for id: UUID) -> URL {
        documentsURL.appendingPathComponent("\(id.uuidString).jpg")
    }
    
    private func saveImage(_ image: UIImage?, for id: UUID) {
        guard let image else {
            deleteImage(for: id)
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        do {
            try data.write(to: imageURL(for: id), options: .atomic)
        } catch {
            print("Failed to save image for \(id): \(error)")
        }
    }
    
    private func loadImage(for id: UUID) -> UIImage? {
        UIImage(contentsOfFile: imageURL(for: id).path)
    }
    
    private func deleteImage(for id: UUID) {
        try? FileManager.default.removeItem(at: imageURL(for: id))
    }
}
