//
//  VerifyVerloopView.swift
//  VerifyVerloopSwiftUI
//
//  Created by Pankaj Patel on 28/06/24.
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
