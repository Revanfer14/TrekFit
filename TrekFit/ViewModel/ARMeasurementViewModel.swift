//
//  ARMeasurementViewModel.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//


//
//  ARMeasurementViewModel.swift
//  TrekFit
//
//  Created by Jonathan Basuki on 05/05/26.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

final class ARMeasurementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var points: [SIMD3<Float>] = []
    @Published var currentHeight: Double = 0
    @Published var sessionReady: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Reference
    weak var arView: ARView?
    
    // MARK: - Public Methods
    func addPoint() {
        guard let arView = arView else { return }
        let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        guard let result = arView.raycast(
            from: center,
            allowing: .estimatedPlane,
            alignment: .any
        ).first else {
            errorMessage = "Move device slowly to detect surface"
            return
        }
        
        errorMessage = nil
        
        let worldPos = SIMD3<Float>(
            result.worldTransform.columns.3.x,
            result.worldTransform.columns.3.y,
            result.worldTransform.columns.3.z
        )
        
        if points.count >= 2 {
            points.removeAll()
            currentHeight = 0
            clearAnchors()
        }
        
        points.append(worldPos)
        placeSphere(at: worldPos)
        
        if points.count == 2 {
            calculateHeight()
        }
    }
    
    func reset() {
        points.removeAll()
        currentHeight = 0
        clearAnchors()
    }
    
    // MARK: - Private Methods
    private func calculateHeight() {
        guard points.count == 2 else { return }
        let dy = abs(points[1].y - points[0].y)
        currentHeight = Double(dy) * 100.0
        Haptics.notify(.success)
    }
    
    private func placeSphere(at position: SIMD3<Float>) {
        guard let arView = arView else { return }
        let sphere = MeshResource.generateSphere(radius: 0.008)
        let material = SimpleMaterial(color: .orange, isMetallic: false)
        let entity = ModelEntity(mesh: sphere, materials: [material])
        let anchor = AnchorEntity(world: position)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
    }
    
    private func clearAnchors() {
        arView?.scene.anchors.removeAll()
    }
}

struct ARMeasurementView: UIViewRepresentable {
    @ObservedObject var viewModel: ARMeasurementViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = context.coordinator
        arView.backgroundColor = .clear
        
        viewModel.arView = arView
        
        DispatchQueue.main.async {
            viewModel.sessionReady = true
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, ARSessionDelegate {
        let viewModel: ARMeasurementViewModel
        
        init(viewModel: ARMeasurementViewModel) {
            self.viewModel = viewModel
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            let message = error.localizedDescription
            DispatchQueue.main.async {
                self.viewModel.errorMessage = "AR Error: " + message
            }
        }
        
        func sessionWasInterrupted(_ session: ARSession) {
            print("AR session interrupted")
        }
        
        func sessionInterruptionEnded(_ session: ARSession) {
            print("AR session resumed")
        }
    }
}


