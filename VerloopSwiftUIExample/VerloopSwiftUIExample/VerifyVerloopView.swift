//
//  VerifyVerloopView.swift
//  VerloopSwiftUIExample
//
//  Created by Pankaj Patel on 01/08/24.
//


import SwiftUI
struct VerifyVerloopView: View {
    @State private var isLinkActive = false
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Button(action: {
                    self.isLinkActive = true
                }) {
                    Text("Launch Verloop")
                }
            }
            .navigationBarTitle(Text("Verify Verloop"))
            .fullScreenCover(isPresented: $isLinkActive){
                VerifyVerloopRepresentable()
            }
        }
    }
}
