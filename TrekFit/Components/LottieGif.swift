//
//  LottieGif.swift
//  TrekFit
//
//  Created by Revan Ferdinand on 05/05/26.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name, bundle: .main)
        view.loopMode = loopMode
        view.play()
        view.contentMode = .scaleAspectFill
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

