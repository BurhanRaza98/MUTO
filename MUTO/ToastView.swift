//
//  ToastView.swift
//  MUTO
//
//  Created by Burhan Raza on 17/12/24.
//


import SwiftUI

struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding(.bottom, 90) 
    }
}
