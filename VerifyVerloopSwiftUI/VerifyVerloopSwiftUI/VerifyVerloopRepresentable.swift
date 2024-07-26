//
//  VefifyVerloopView.swift
//  VerifyVerloopSwiftUI
//
//  Created by Pankaj Patel on 28/06/24.
//

import SwiftUI
import PhotosUI
import VerloopSDK

struct VerifyVerloopRepresentable: UIViewControllerRepresentable {
//  @Binding var pickerResult: [UIImage]
//  @Binding var isPresented: Bool
  
  
    
  func makeUIViewController(context: Context) -> some UIViewController {
    var mSDK:VerloopSDK?
    mSDK = VerloopSDK(config: VLConfig(clientId: "tarun"))
    let cntrl = mSDK!.getNavController()
    mSDK?.observeLiveChatEventsOn(vlEventDelegate: context.coordinator)
    return cntrl
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: VLEventDelegate {
    private let parent: VerifyVerloopRepresentable
    
    init(_ parent: VerifyVerloopRepresentable) {
      self.parent = parent
    }
      func onChatMaximized() {
          print("ref onChatMaximized")
      }
      func onChatMinimized() {
          print("ref onChatMinimized")
      }
      func onChatStarted() {
          print("ref onChatStarted")
      }
      func onChatEnded() {
          print("ref onChatEnded")
      }
      func onLogoutComplete() {
          print("ref onLogoutComplete")
      }
      func onWidgetLoaded() {
          print("ref onWidgetLoaded")
      }
      func onIncomingMessage(_ message:Any) {
          print("ref onIncomingMessage \(message)")
      }
  }
}
