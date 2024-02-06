//
//  NumberPicker.swift
//  harmny.app Watch App
//
//  Created by Roman Rastegaev on 09.01.2024.
//

import SwiftUI

struct NumberPickerView: View {
    @Binding var selectedNumber: Int
    
    var body: some View {
        Picker("Count", selection: $selectedNumber) {
            ForEach(0..<1000) { number in
                Text("\(number)").tag(number)
            }
        }
        .frame(width: 54, height: 54)
    }
}
