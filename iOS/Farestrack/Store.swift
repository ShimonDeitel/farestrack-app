import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [FareItem] = []
    @Published var isPro: Bool = false

    static let freeLimit = 15

    private let fileName = "farestrack_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([FareItem].self, from: data) else {
            items = [
        FareItem(provider: "Uber", amount: 18.4, purpose: "Airport"),
        FareItem(provider: "Lyft", amount: 9.75, purpose: "Commute"),
        FareItem(provider: "Taxi", amount: 24.0, purpose: "Client meeting")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: FareItem) -> Bool {
        guard canAddMore else { return false }
        items.append(item)
        save()
        return true
    }

    func update(_ item: FareItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: FareItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
