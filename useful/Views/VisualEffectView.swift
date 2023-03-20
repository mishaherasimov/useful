//
//  VisualEffectView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-19.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
