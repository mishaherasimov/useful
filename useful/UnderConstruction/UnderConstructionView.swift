//
//  UnderConstructionView.swift
//  useful
//
//  Created by Mykhailo Herasimov on 2023-03-19.
//  Copyright © 2023 Mykhailo Herasimov. All rights reserved.
//

import SwiftUI

struct UnderConstructionView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))

            VStack {
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundColor(Color.white)
                            .frame(width: Constants.closeButtonSize, height: Constants.closeButtonSize)
                    }
                }
                Spacer()
            }
            .padding(Constants.closeButtonInsets)

            VStack(spacing: Constants.contentSpacing) {
                Image(uiImage: #imageLiteral(resourceName: "under-construction"))
                Text("It Is under Construction")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(Color.clear)
    }
}

extension UnderConstructionView {
    private enum Constants {
        static let closeButtonInsets: EdgeInsets = .create(top: 45, trailing: 32)
        static let closeButtonSize: CGFloat = 34
        static let contentSpacing: CGFloat = 16
    }
}

struct UnderConstructionView_Previews: PreviewProvider {
    static var previews: some View {
        UnderConstructionView()
            .background(Color.gray)
    }
}
