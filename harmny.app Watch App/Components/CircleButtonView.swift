//
//  CircleButtonView.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 07.01.2024.
//

import SwiftUI

struct CircleButtonView: View {
    
    let color: Color
    let imageName: String
    let action: () -> Void
    
    private let size = 36.0
    
    init(color: Color, imageName: String, _ action: @escaping () -> Void) {
        self.color = color
        self.imageName = imageName
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
        .frame(width: size, height: size)
        .buttonStyle(.plain)
    }
}
