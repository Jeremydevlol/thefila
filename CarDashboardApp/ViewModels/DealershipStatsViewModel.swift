import Foundation
import SwiftUI

enum DealershipPeriodScope: String, CaseIterable, Identifiable {
    case month = "Mes"
    case quarter = "Trimestre"
    case year = "Año"

    var id: String { rawValue }
}

@MainActor
final class DealershipStatsViewModel: ObservableObject {
    @Published var periodScope: DealershipPeriodScope = .month
    /// Etiqueta visible del período (ej. mes y año).
    @Published var periodDisplayLabel: String = "Marzo 2026"

    @Published var totalStockValue: String = "128"
    @Published var totalStockBadge: String = "+18 min"
    @Published var completedTreatmentsCount: Int = 42
    @Published var salesProfit: String = "12"
    @Published var newPatientsCount: Int = 24
    @Published var capturedChangePercent: Int = 12
    @Published var commercialCommissions: String = "6 lugares santos · dedicación"
    @Published var commissionsSubtitle: String = "Kotel · Kever Rakhel · Modiin · Yerushalayim · Tzjfat · Migdal David"
    @Published var totalDealershipEarnings: String = "38"
    @Published var totalEarningsSubtitle: String = "Peticiones acompañadas por rabín o hazan"
}
