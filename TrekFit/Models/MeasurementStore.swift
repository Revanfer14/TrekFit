//
//  MeasurementStore.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI
import Combine

enum MeasurementUnit: String, CaseIterable, Codable {
    case cm, inch
    
    var symbol: String {
        switch self {
        case .cm: return "cm"
        case .inch: return "in"
        }
    }
}

final class MeasurementStore: ObservableObject {
    // Persisted globally across the app
    @AppStorage("stepHeight") var stepHeight: Double = 30.0
    @AppStorage("measurementUnit") var unitRaw: String = MeasurementUnit.cm.rawValue
    
    var unit: MeasurementUnit {
        get { MeasurementUnit(rawValue: unitRaw) ?? .cm }
        set { unitRaw = newValue.rawValue }
    }
    
    // Validation
    func updateHeight(_ value: Double) {
        let clamped = max(5, min(200, value)) // reasonable range
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            stepHeight = clamped
        }
    }
}
