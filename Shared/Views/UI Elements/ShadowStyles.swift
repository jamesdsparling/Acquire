//
//  ShadowStyles.swift
//  Acquire
//
//  Created by James Sparling on 11/01/2021.
//

import SwiftUI

struct ShadowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
                .background(
                    Color(UIColor.systemBackground).opacity(configuration.isPressed ? 1 : 0.5)
                        .cornerRadius(50)
                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                )
        }
}

struct ShadowTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
                .padding(10)
                .background(
                    Color(UIColor.systemGray5)
                        .cornerRadius(50)
                        .shadow(color: Color.black.opacity(0.5), radius: 15, x: 2, y: 2)
                )
        }
}


struct ShadowStyles_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Text("Button")
        }
        .buttonStyle(ShadowButtonStyle())
//        .environment(\.colorScheme, .dark)
    }
}
