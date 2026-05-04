//
//  ARMeasurementService.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 04/05/26.
//

import ARKit
import RealityKit
import SwiftUI
import Combine

enum MeasureStep {
    case idle
    case placingBottom
    case placingTop
    case done
}

@MainActor
final class ARMeasurementSession: NSObject, ObservableObject {

    // MARK: - Published
    @Published var measureStep: MeasureStep = .idle
    @Published var measuredHeightCM: Double? = nil
    @Published var statusMessage: String = "Point camera at the base of the object"
    @Published var bottomAnchorPlaced: Bool = false
    @Published var isARReady: Bool = false
    @Published var showError: String? = nil

    // MARK: - AR References
    var arView: ARView?

    private var bottomWorldPosition: SIMD3<Float>? = nil
    private var topWorldPosition: SIMD3<Float>? = nil

    private var bottomEntity: ModelEntity?
    private var topEntity: ModelEntity?
    private var lineEntity: ModelEntity?

    // MARK: - Setup ARView
    func setup(arView: ARView) {
        self.arView = arView

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        arView.session.delegate = self
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arView.debugOptions = []

        // Add tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)

        measureStep = .placingBottom
        statusMessage = "Tap to place BOTTOM point of the object"
    }

    // MARK: - Reset
    func reset() {
        bottomWorldPosition = nil
        topWorldPosition = nil
        measuredHeightCM = nil
        measureStep = .placingBottom
        statusMessage = "Tap to place BOTTOM point of the object"
        bottomAnchorPlaced = false

        bottomEntity?.removeFromParent()
        topEntity?.removeFromParent()
        lineEntity?.removeFromParent()
        bottomEntity = nil
        topEntity = nil
        lineEntity = nil
    }

    // MARK: - Handle Tap
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = sender.location(in: arView)

        guard let result = arView.raycast(
            from: location,
            allowing: .estimatedPlane,
            alignment: .any
        ).first else {
            showError = "No surface detected. Move camera slowly."
            return
        }

        let worldPos = result.worldTransform.columns.3
        let position = SIMD3<Float>(worldPos.x, worldPos.y, worldPos.z)

        switch measureStep {
        case .placingBottom:
            bottomWorldPosition = position
            placeMarker(at: position, color: .systemOrange, isBottom: true)
            bottomAnchorPlaced = true
            measureStep = .placingTop
            statusMessage = "Now tap the TOP of the object"
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

        case .placingTop:
            topWorldPosition = position
            placeMarker(at: position, color: .systemBlue, isBottom: false)
            calculateHeight()
            measureStep = .done
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        case .done:
            // Re-tap to reset
            reset()

        default:
            break
        }
    }

    // MARK: - Place Visual Marker
    private func placeMarker(at position: SIMD3<Float>, color: UIColor, isBottom: Bool) {
        guard let arView = arView else { return }

        let sphere = MeshResource.generateSphere(radius: 0.01)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: sphere, materials: [material])

        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)

        if isBottom {
            bottomEntity = entity
        } else {
            topEntity = entity
            drawLine()
        }
    }

    // MARK: - Draw Measurement Line
    private func drawLine() {
        guard let bottom = bottomWorldPosition, let top = topWorldPosition,
              let arView = arView else { return }

        let midpoint = (bottom + top) / 2
        let distance = simd_distance(bottom, top)

        let cylinder = MeshResource.generateCylinder(height: distance, radius: 0.003)
        let material = SimpleMaterial(color: .systemYellow.withAlphaComponent(0.8), isMetallic: false)
        let entity = ModelEntity(mesh: cylinder, materials: [material])

        // Orient cylinder to point from bottom to top
        let direction = normalize(top - bottom)
        let up = SIMD3<Float>(0, 1, 0)
        let rotation = simd_quatf(from: up, to: direction)
        entity.transform.rotation = rotation

        let anchor = AnchorEntity(world: midpoint)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        lineEntity = entity
    }

    // MARK: - Height Calculation
    private func calculateHeight() {
        guard let bottom = bottomWorldPosition, let top = topWorldPosition else { return }

        // Use absolute Y difference for height (vertical distance)
        let heightMeters = abs(top.y - bottom.y)

        // Fallback to 3D distance if points are at similar Y
        let distance3D = simd_distance(bottom, top)
        let finalHeight = heightMeters > 0.01 ? heightMeters : distance3D

        let heightCM = Double(finalHeight) * 100.0
        let rounded = (heightCM * 10).rounded() / 10 // 1 decimal

        measuredHeightCM = rounded
        statusMessage = String(format: "Height: %.1f cm", rounded)
    }
}

// MARK: - ARSessionDelegate
extension ARMeasurementSession: ARSessionDelegate {
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async {
            if !self.isARReady {
                self.isARReady = true
            }
        }
    }

    nonisolated func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.showError = error.localizedDescription
        }
    }

    nonisolated func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.showError = "AR session interrupted"
        }
    }
}
