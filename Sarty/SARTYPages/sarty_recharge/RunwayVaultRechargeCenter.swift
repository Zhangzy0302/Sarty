import Foundation
import StoreKit

struct RunwayVaultRechargePack {
    let runwayVaultProductId: String
    let runwayVaultWardrobeValue: Int
    let runwayVaultRunwayPrice: Double

    var runwayVaultDisplayPrice: String {
        String(format: "$%.2f", runwayVaultRunwayPrice)
    }
}

enum RunwayVaultRechargeResult {
    case success
    case cancelled
    case pending
    case failed(String)
}

enum RunwayVaultRechargeCenter {
    static let runwayVaultAtelierCatalog: [RunwayVaultRechargePack] = [
        RunwayVaultRechargePack(runwayVaultProductId: "jsazziwrhssehxtl", runwayVaultWardrobeValue: 400, runwayVaultRunwayPrice: 0.99),
        RunwayVaultRechargePack(runwayVaultProductId: "ckewztbgylqwrdjk", runwayVaultWardrobeValue: 800, runwayVaultRunwayPrice: 1.99),
        RunwayVaultRechargePack(runwayVaultProductId: "kzqjvhmntrpaxcwl", runwayVaultWardrobeValue: 2190, runwayVaultRunwayPrice: 3.99),
        RunwayVaultRechargePack(runwayVaultProductId: "oopswwwahexmuuoj", runwayVaultWardrobeValue: 2450, runwayVaultRunwayPrice: 4.99),
        RunwayVaultRechargePack(runwayVaultProductId: "bnyfudrkeqmszhto", runwayVaultWardrobeValue: 3950, runwayVaultRunwayPrice: 7.99),
        RunwayVaultRechargePack(runwayVaultProductId: "xadzihhaqhujitrw", runwayVaultWardrobeValue: 5150, runwayVaultRunwayPrice: 9.99),
        RunwayVaultRechargePack(runwayVaultProductId: "wclpaxjvngortkhe", runwayVaultWardrobeValue: 7700, runwayVaultRunwayPrice: 14.99),
        RunwayVaultRechargePack(runwayVaultProductId: "cyuftdupmpewcqco", runwayVaultWardrobeValue: 10800, runwayVaultRunwayPrice: 19.99),
        RunwayVaultRechargePack(runwayVaultProductId: "ejbphlsmmvvarggv", runwayVaultWardrobeValue: 29400, runwayVaultRunwayPrice: 49.99),
        RunwayVaultRechargePack(runwayVaultProductId: "zyfmbecofimyzlmi", runwayVaultWardrobeValue: 63700, runwayVaultRunwayPrice: 99.99)
    ]

    static func runwayVaultPackage(for runwayVaultProductId: String) -> RunwayVaultRechargePack? {
        runwayVaultAtelierCatalog.first { $0.runwayVaultProductId == runwayVaultProductId }
    }

    static func runwayVaultPayloadCatalog() -> [[String: Any]] {
        runwayVaultAtelierCatalog.map {
            [
                "key": $0.runwayVaultProductId,
                "cions": $0.runwayVaultWardrobeValue,
                "money": $0.runwayVaultDisplayPrice
            ]
        }
    }

    static func runwayVaultPurchaseCurrentUser(
        productId runwayVaultProductId: String,
        storage runwayVaultStorage: WardrobeShareStorageManager
    ) async -> RunwayVaultRechargeResult {
        await withCheckedContinuation { runwayVaultContinuation in
            RunwayVaultStoreKitOneCenter.shared.runwayVaultPurchaseCurrentUser(
                productId: runwayVaultProductId,
                storage: runwayVaultStorage
            ) { runwayVaultResult in
                runwayVaultContinuation.resume(returning: runwayVaultResult)
            }
        }
    }

    static func runwayVaultPurchaseBPackage(
        productId runwayVaultProductId: String,
        orderCode runwayVaultOrderCode: String
    ) async -> RunwayVaultRechargeResult {
        await withCheckedContinuation { runwayVaultContinuation in
            RunwayVaultStoreKitOneCenter.shared.runwayVaultPurchaseBPackage(
                productId: runwayVaultProductId,
                orderCode: runwayVaultOrderCode
            ) { runwayVaultResult in
                runwayVaultContinuation.resume(returning: runwayVaultResult)
            }
        }
    }

    static func runwayVaultSilentlyPrepareStoreKitProducts() {
        RunwayVaultStoreKitOneCenter.shared.runwayVaultSilentlyPrepareProducts()
    }
}

final class RunwayVaultStoreKitOneCenter: NSObject {
    static let shared = RunwayVaultStoreKitOneCenter()

    private var runwayVaultProductRequest: SKProductsRequest?
    private var runwayVaultProductCache: [String: SKProduct] = [:]
    private var runwayVaultPendingUserIds: [String: String] = [:]
    private var runwayVaultPendingOrderCodes: [String: String] = [:]
    private var runwayVaultPendingCompletions: [String: (RunwayVaultRechargeResult) -> Void] = [:]
    private var runwayVaultRetryCount = 0
    private var runwayVaultTotalRequestCount = 0
    private let runwayVaultMaxTotalRequestCount = 10
    private let runwayVaultMaxRetryCount = 10
    private var runwayVaultIsRequesting = false
    private let runwayVaultStorage = WardrobeShareStorageManager.shared

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    func runwayVaultSilentlyPrepareProducts() {
        guard runwayVaultTotalRequestCount < runwayVaultMaxTotalRequestCount else { return }
        guard !runwayVaultIsRequesting else { return }
        guard runwayVaultProductCache.isEmpty else { return }

        let runwayVaultProductIds = Set(
            RunwayVaultRechargeCenter.runwayVaultAtelierCatalog.map(\.runwayVaultProductId)
        )
        guard !runwayVaultProductIds.isEmpty else { return }

        runwayVaultIsRequesting = true
        runwayVaultTotalRequestCount += 1

        runwayVaultProductRequest?.cancel()
        runwayVaultProductRequest = SKProductsRequest(productIdentifiers: runwayVaultProductIds)
        runwayVaultProductRequest?.delegate = self
        runwayVaultProductRequest?.start()
    }

    func runwayVaultPurchaseCurrentUser(
        productId runwayVaultProductId: String,
        storage runwayVaultStorage: WardrobeShareStorageManager,
        completion runwayVaultCompletion: @escaping (RunwayVaultRechargeResult) -> Void
    ) {
        guard let runwayVaultPack = runwayVaultPackage(for: runwayVaultProductId) else {
            runwayVaultCompletion(.failed("Payment package unavailable"))
            return
        }

        let runwayVaultUserId = runwayVaultStorage.wardrobeShareGetCurrentUserId()
        guard !runwayVaultUserId.isEmpty else {
            runwayVaultCompletion(.failed("Please sign in first"))
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            runwayVaultCompletion(.failed("Payment is unavailable"))
            return
        }

        runwayVaultPendingUserIds[runwayVaultProductId] = runwayVaultUserId
        runwayVaultPendingCompletions[runwayVaultProductId] = runwayVaultCompletion

        guard let runwayVaultCachedProduct = runwayVaultProductCache[runwayVaultProductId] else {
            runwayVaultPendingUserIds.removeValue(forKey: runwayVaultProductId)
            runwayVaultPendingCompletions.removeValue(forKey: runwayVaultProductId)
            runwayVaultSilentlyPrepareProducts()
            runwayVaultCompletion(.failed("Products are loading"))
            return
        }

        runwayVaultStartPayment(product: runwayVaultCachedProduct)
        _ = runwayVaultPack
    }

    func runwayVaultPurchaseBPackage(
        productId runwayVaultProductId: String,
        orderCode runwayVaultOrderCode: String,
        completion runwayVaultCompletion: @escaping (RunwayVaultRechargeResult) -> Void
    ) {
        guard let runwayVaultPack = runwayVaultPackage(for: runwayVaultProductId) else {
            runwayVaultCompletion(.failed("Payment package unavailable"))
            return
        }

        guard SKPaymentQueue.canMakePayments() else {
            runwayVaultCompletion(.failed("Payment is unavailable"))
            return
        }

        runwayVaultPendingOrderCodes[runwayVaultProductId] = runwayVaultOrderCode
        runwayVaultPendingCompletions[runwayVaultProductId] = runwayVaultCompletion

        guard let runwayVaultCachedProduct = runwayVaultProductCache[runwayVaultProductId] else {
            runwayVaultPendingOrderCodes.removeValue(forKey: runwayVaultProductId)
            runwayVaultPendingCompletions.removeValue(forKey: runwayVaultProductId)
            runwayVaultSilentlyPrepareProducts()
            runwayVaultCompletion(.failed("Products are loading"))
            return
        }

        runwayVaultStartPayment(product: runwayVaultCachedProduct)
        _ = runwayVaultPack
    }

    private func runwayVaultPackage(for runwayVaultProductId: String) -> RunwayVaultRechargePack? {
        RunwayVaultRechargeCenter.runwayVaultPackage(for: runwayVaultProductId)
    }

    private func runwayVaultCreditUser(for runwayVaultProductId: String) -> RunwayVaultRechargeResult {
        guard let runwayVaultPack = runwayVaultPackage(for: runwayVaultProductId) else {
            return .failed("Payment package unavailable")
        }

        guard let runwayVaultUserId = runwayVaultPendingUserIds[runwayVaultProductId],
              !runwayVaultUserId.isEmpty else {
            return .failed("Please sign in first")
        }

        runwayVaultStorage.wardrobeShareUpdateUser(uid: runwayVaultUserId) { runwayVaultUser in
            var runwayVaultUpdatedUser = runwayVaultUser
            runwayVaultUpdatedUser.closetProfileWalletBalance += runwayVaultPack.runwayVaultWardrobeValue
            return runwayVaultUpdatedUser
        }

        return .success
    }

    private func runwayVaultStartPayment(product runwayVaultProduct: SKProduct) {
        Task { @MainActor in
            RunwaySignalHUDCenter.shared.runwaySignalShowLoading()
            SKPaymentQueue.default().add(SKPayment(product: runwayVaultProduct))
        }
    }

    private func runwayVaultComplete(
        productId runwayVaultProductId: String,
        result runwayVaultResult: RunwayVaultRechargeResult
    ) {
        let runwayVaultCompletion = runwayVaultPendingCompletions.removeValue(forKey: runwayVaultProductId)
        runwayVaultPendingUserIds.removeValue(forKey: runwayVaultProductId)
        runwayVaultPendingOrderCodes.removeValue(forKey: runwayVaultProductId)

        DispatchQueue.main.async {
            RunwaySignalHUDCenter.shared.runwaySignalHideLoading()
            runwayVaultCompletion?(runwayVaultResult)
        }
    }

    private func runwayVaultReceiptDataString() -> String {
        guard let runwayVaultReceiptURL = Bundle.main.appStoreReceiptURL,
              let runwayVaultReceiptData = try? Data(contentsOf: runwayVaultReceiptURL) else {
            return ""
        }

        return runwayVaultReceiptData.base64EncodedString()
    }

    private func runwayVaultHandleBPackagePurchasedTransaction(
        _ runwayVaultTransaction: SKPaymentTransaction,
        queue runwayVaultQueue: SKPaymentQueue
    ) {
        let runwayVaultProductId = runwayVaultTransaction.payment.productIdentifier

        guard let runwayVaultPack = runwayVaultPackage(for: runwayVaultProductId) else {
            runwayVaultQueue.finishTransaction(runwayVaultTransaction)
            runwayVaultComplete(productId: runwayVaultProductId, result: .failed("Payment package unavailable"))
            return
        }

        let runwayVaultPurchaseID = runwayVaultTransaction.transactionIdentifier ?? ""
        let runwayVaultVerificationData = runwayVaultReceiptDataString()
        let runwayVaultOrderCode = runwayVaultPendingOrderCodes[runwayVaultProductId] ?? closetCharmUsersOrderCode

        Task {
            do {
                let runwayVaultDidVerify = try await TrendThreadApiCall().trendThreadPayCall(
                    purchaseID: runwayVaultPurchaseID,
                    serverVerificationData: runwayVaultVerificationData,
                    orderCode: runwayVaultOrderCode
                )

                await MainActor.run {
                    runwayVaultQueue.finishTransaction(runwayVaultTransaction)

                    if runwayVaultDidVerify {
                        RunwayRippleAdjustManager.shared.runwayRippleTrackRechargeSuccess(
                            dollar: runwayVaultPack.runwayVaultRunwayPrice
                        )
                        runwayVaultComplete(productId: runwayVaultProductId, result: .success)
                    } else {
                        runwayVaultComplete(productId: runwayVaultProductId, result: .failed("Purchase unverified"))
                    }
                }
            } catch {
                await MainActor.run {
                    runwayVaultQueue.finishTransaction(runwayVaultTransaction)
                    runwayVaultComplete(productId: runwayVaultProductId, result: .failed(error.localizedDescription))
                }
            }
        }
    }

    private func runwayVaultRetryFetchProducts() {
        runwayVaultRetryCount += 1

        guard runwayVaultRetryCount < runwayVaultMaxRetryCount,
              runwayVaultTotalRequestCount < runwayVaultMaxTotalRequestCount else {
            return
        }

        let runwayVaultDelay = pow(2.0, Double(runwayVaultRetryCount))
        DispatchQueue.main.asyncAfter(deadline: .now() + runwayVaultDelay) { [weak self] in
            self?.runwayVaultSilentlyPrepareProducts()
        }
    }
}

extension RunwayVaultStoreKitOneCenter: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.runwayVaultIsRequesting = false
            self.runwayVaultRetryCount = 0
            self.runwayVaultProductCache = Dictionary(
                uniqueKeysWithValues: response.products.map { ($0.productIdentifier, $0) }
            )

            if response.products.isEmpty {
                self.runwayVaultRetryFetchProducts()
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.runwayVaultIsRequesting = false
            self.runwayVaultRetryFetchProducts()
        }
    }
}

extension RunwayVaultStoreKitOneCenter: SKPaymentTransactionObserver {
    func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]
    ) {
        transactions.forEach { runwayVaultTransaction in
            let runwayVaultProductId = runwayVaultTransaction.payment.productIdentifier

            switch runwayVaultTransaction.transactionState {
            case .purchased:
                if ClosetCharmAppStorage.closetCharmIsB {
                    runwayVaultHandleBPackagePurchasedTransaction(runwayVaultTransaction, queue: queue)
                } else {
                    let runwayVaultResult = runwayVaultCreditUser(for: runwayVaultProductId)
                    queue.finishTransaction(runwayVaultTransaction)

                    if case .success = runwayVaultResult,
                       let runwayVaultPack = runwayVaultPackage(for: runwayVaultProductId) {
                        RunwayRippleAdjustManager.shared.runwayRippleTrackRechargeSuccess(
                            dollar: runwayVaultPack.runwayVaultRunwayPrice
                        )
                    }

                    runwayVaultComplete(productId: runwayVaultProductId, result: runwayVaultResult)
                }

            case .restored:
                queue.finishTransaction(runwayVaultTransaction)

            case .failed:
                let runwayVaultError = runwayVaultTransaction.error as? SKError
                queue.finishTransaction(runwayVaultTransaction)
                if runwayVaultError?.code == .paymentCancelled {
                    runwayVaultComplete(productId: runwayVaultProductId, result: .cancelled)
                } else {
                    runwayVaultComplete(
                        productId: runwayVaultProductId,
                        result: .failed(runwayVaultTransaction.error?.localizedDescription ?? "Payment failed")
                    )
                }

            case .purchasing:
                break
                
            case .deferred:
                runwayVaultComplete(productId: runwayVaultProductId, result: .pending)

            @unknown default:
                break
            }
        }
    }
}
