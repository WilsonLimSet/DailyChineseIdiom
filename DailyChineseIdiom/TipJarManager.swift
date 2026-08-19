import Foundation
import StoreKit

/// Consumable "tip" purchases. Nothing is unlocked by tipping — the app stays fully
/// free — so the only state we keep is whether the user has ever tipped, to say thanks.
@MainActor
final class TipJarManager: ObservableObject {
    static let shared = TipJarManager()

    /// Must match the product IDs created in App Store Connect.
    /// A `.tip.medium` product also exists in App Store Connect as an unsubmitted draft;
    /// add its ID here (and to TipJar.storekit) to bring the middle tier back.
    static let productIDs = [
        "com.wilsonlimsetiawan.dailychineseidioms.tip.small",
        "com.wilsonlimsetiawan.dailychineseidioms.tip.large"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchasingProductID: Product.ID?
    @Published private(set) var hasTipped: Bool
    @Published var showThankYou = false
    @Published var errorMessage: String?

    private let hasTippedKey = "hasTippedJar"
    private var updatesTask: Task<Void, Never>?

    private init() {
        hasTipped = UserDefaults.standard.bool(forKey: hasTippedKey)
        // Catch transactions that finish outside a purchase call (e.g. Ask to Buy approvals)
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    /// Emoji shown next to each tier. Matched on the ID suffix so tiers can be added or
    /// removed from `productIDs` without this going out of bounds.
    func symbol(for product: Product) -> String {
        if product.id.hasSuffix(".tip.small") { return "🥟" }
        if product.id.hasSuffix(".tip.medium") { return "🍜" }
        if product.id.hasSuffix(".tip.large") { return "🍽️" }
        return "❤️"
    }

    func loadProducts() async {
        // Retry while any tier is still missing — a newly created product can take a while to
        // propagate, and we don't want a partial load to stick for the rest of the session.
        guard !isLoadingProducts, products.count < Self.productIDs.count else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let loaded = try await Product.products(for: Self.productIDs)
            // Keep the tiers in price order rather than the order the API returns them
            products = loaded.sorted { $0.price < $1.price }

            let missing = Set(Self.productIDs).subtracting(loaded.map(\.id))
            if !missing.isEmpty {
                print("TipJar: no product returned for \(missing.sorted()). Check the ID exists in App Store Connect (and has propagated), or that a StoreKit configuration file is selected in the scheme.")
            }
        } catch {
            // Leave products as-is — the tip section simply stays hidden when empty
            print("TipJar: failed to load products - \(error)")
        }
    }

    func purchase(_ product: Product) async {
        guard purchasingProductID == nil else { return }
        purchasingProductID = product.id
        defer { purchasingProductID = nil }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                await handle(verification)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        // Tips are consumables: mark them finished so StoreKit stops replaying them
        await transaction.finish()

        guard Self.productIDs.contains(transaction.productID) else { return }
        hasTipped = true
        UserDefaults.standard.set(true, forKey: hasTippedKey)
        showThankYou = true
    }
}
