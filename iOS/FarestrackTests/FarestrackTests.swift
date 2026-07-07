import XCTest
@testable import Farestrack

final class FarestrackTests: XCTestCase {
    @MainActor
    func makeEmptyStore() -> Store {
        let store = Store()
        store.items = []
        return store
    }

    @MainActor
    func testAddIncreasesCount() {
        let store = makeEmptyStore()
        let item = FareItem(provider: "Test", amount: 1.0, purpose: "Test")
        _ = store.add(item)
        XCTAssertEqual(store.items.count, 1)
    }

    @MainActor
    func testFreeLimitBlocksAdd() {
        let store = makeEmptyStore()
        for _ in 0..<Store.freeLimit {
            _ = store.add(FareItem(provider: "Test", amount: 1.0, purpose: "Test"))
        }
        let result = store.add(FareItem(provider: "Test", amount: 1.0, purpose: "Test"))
        XCTAssertFalse(result)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    @MainActor
    func testProBypassesFreeLimit() {
        let store = makeEmptyStore()
        store.isPro = true
        for _ in 0..<(Store.freeLimit + 5) {
            _ = store.add(FareItem(provider: "Test", amount: 1.0, purpose: "Test"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    @MainActor
    func testDeleteRemovesItem() {
        let store = makeEmptyStore()
        let item = FareItem(provider: "Test", amount: 1.0, purpose: "Test")
        _ = store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    @MainActor
    func testDeleteAtOffsets() {
        let store = makeEmptyStore()
        _ = store.add(FareItem(provider: "Test", amount: 1.0, purpose: "Test"))
        _ = store.add(FareItem(provider: "Test", amount: 1.0, purpose: "Test"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    @MainActor
    func testUpdateModifiesItem() {
        let store = makeEmptyStore()
        let item = FareItem(provider: "Test", amount: 1.0, purpose: "Test")
        _ = store.add(item)
        var updated = item
        updated.provider = "Updated"
        store.update(updated)
        XCTAssertEqual(store.items.first?.provider, "Updated")
    }

    @MainActor
    func testCanAddMoreTrueWhenUnderLimit() {
        let store = makeEmptyStore()
        XCTAssertTrue(store.canAddMore)
    }
}
