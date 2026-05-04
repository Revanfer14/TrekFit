//
//  ChesterTestView2.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 04/05/26.
//

import SwiftUI

struct ChesterTestView: View {


    @StateObject private var viewModel: ChesterTestViewModel
    @State private var showStopConfirm: Bool = false

    init(hrMonitor: HeartRateMonitor) {
        _viewModel = StateObject(wrappedValue: ChesterTestViewModel(hrMonitor: hrMonitor))
    }

    private var isDark: Bool          { viewModel.isDark }
    private var bgColor: Color        { isDark ? .black             : .white }
    private var primaryText: Color    { isDark ? .white             : .black }
    private var trackColor: Color     { isDark ? Color(white: 0.25) : Color(hex: "E0E0E0") }
    private var cardBg: Color         { isDark ? .white             : .black }
    private var cardText: Color       { isDark ? .black             : .white }

    // MARK: - Body

    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.08), value: isDark)

            VStack(alignment: .leading, spacing: 0) {

                Spacer()

                // ── Elapsed time ──────────────────────────────────────────
                Text(viewModel.elapsedString)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(primaryText)
                    .padding(.horizontal, 32)
                    .animation(.none, value: viewModel.elapsedString)

                // ── Stage label ───────────────────────────────────────────
                Text("Stage \(viewModel.currentStage.number) / \(viewModel.stages.count)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(primaryText)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)

                // ── Live BPM ──────────────────────────────────────────────
                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(Int(viewModel.currentHR))")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(primaryText)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: Int(viewModel.currentHR))

                    Text("bpm")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(primaryText)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)

                // ── HR progress bar ───────────────────────────────────────
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(trackColor)
                            .frame(height: 12)

                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * viewModel.hrProgress, height: 12)
                            .animation(.linear(duration: 0.3), value: viewModel.hrProgress)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 32)
                .padding(.top, 20)

                // ── % of Max HR ───────────────────────────────────────────
                Text(String(format: "%.0f%% of Max HR", viewModel.hrProgress * 100))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(primaryText)
                    .padding(.horizontal, 32)
                    .padding(.top, 12)

                Spacer()

                // ── Heart Rate Threshold card ─────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(cardBg)

                    VStack(spacing: 4) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(Int(viewModel.hrThreshold))")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(cardText)
                            Text("bpm")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(cardText)
                                .padding(.bottom, 8)
                        }
                        Text("Heart Rate Threshold")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(cardText.opacity(0.7))
                    }
                    .padding(.vertical, 24)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                // ── Stop button ───────────────────────────────────────────
                Button {
                    showStopConfirm = true
                } label: {
                    Text("Stop Test")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.85))
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startTest()
        }
        .onDisappear {
            viewModel.stopAll()
        }
        .confirmationDialog("Stop Test?", isPresented: $showStopConfirm, titleVisibility: .visible) {
            Button("Stop", role: .destructive) {
                viewModel.manualStop()
            }
            Button("Continue", role: .cancel) {}
        }
        .navigationDestination(isPresented: $viewModel.testFinished) {
            // TODO: Replace with ResultsView(viewModel: viewModel)
            Text("Test Finished")
        }
    }
}

// MARK: - Preview

#Preview {
    ChesterTestView(hrMonitor: HeartRateMonitor())
}
