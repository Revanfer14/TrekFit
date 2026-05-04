//
//  MeasurementService.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 04/05/26.
//

import SwiftUI
import Combine

enum MeasurementUnit: String, CaseIterable {
    case centimeter = "cm"
    case inch = "in"

    var symbol: String { rawValue }

    func convert(_ value: Double, to target: MeasurementUnit) -> Double {
        if self == target { return value }
        switch (self, target) {
        case (.centimeter, .inch): return value / 2.54
        case (.inch, .centimeter): return value * 2.54
        default: return value
        }
    }
}

final class MeasurementStore: ObservableObject {

    // MARK: - Persisted State
    @AppStorage("stepHeight_cm") private var stepHeightCM: Double = 30.0
    @AppStorage("preferredUnit") private var preferredUnitRaw: String = MeasurementUnit.centimeter.rawValue

    // MARK: - Published
    @Published var stepHeight: Double = 30.0
    @Published var unit: MeasurementUnit = .centimeter
    @Published var isConfirmed: Bool = false

    // MARK: - Preset values (always in cm internally)
    let presets: [Double] = [20, 30, 35, 40]

    static let shared = MeasurementStore()

    private init() {
        stepHeight = stepHeightCM
        unit = MeasurementUnit(rawValue: preferredUnitRaw) ?? .centimeter
    }

    // MARK: - Displayed value (converted to current unit)
    var displayValue: Double {
        get { MeasurementUnit.centimeter.convert(stepHeight, to: unit) }
    }

    // MARK: - Update from camera or manual
    func update(heightInCM: Double, haptic: Bool = true) {
        let clamped = min(max(heightInCM, 1), 200)
        stepHeight = clamped
        stepHeightCM = clamped
        isConfirmed = false
        if haptic {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    func confirm() {
        isConfirmed = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func toggleUnit() {
        unit = (unit == .centimeter) ? .inch : .centimeter
        preferredUnitRaw = unit.rawValue
        objectWillChange.send()
    }

    // Convert display input back to cm for storage
    func updateFromDisplay(_ displayVal: Double) {
        let inCM = unit.convert(displayVal, to: .centimeter)
        update(heightInCM: inCM, haptic: false)
    }
}
