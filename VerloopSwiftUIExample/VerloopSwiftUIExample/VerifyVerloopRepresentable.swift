//
//  VerifyVerloopRepresentable.swift
//  VerloopSwiftUIExample
//
//  Created by Pankaj Patel on 01/08/24.
//


import SwiftUI
import VerloopSDK

struct VerifyVerloopRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var verloop:VerloopSDK?
        var config = VLConfig(clientId: "reactnative")
        //config.setRecipeId(recipeId id: String?)
        //config.setNotificationToken(notificationToken: string)
        //config.setUserName(username name:String)
        //config.setUserEmail(userEmail email:String)
        //config.setUserPhone(userPhone phone:String)
        //config.setUserParam(key:String, value:String)
        config.setButtonOnClickListener { title, type, payload in
            print("button click listenr called")
        }
        
        config.setUrlRedirectionFlag(canRedirect: false)
  
        config.setUrlClickListener { url in
            print("URL click listener called")
        }
        
        verloop = VerloopSDK(config: config)
        let chatController = verloop!.getNavController()
        verloop?.observeLiveChatEventsOn(vlEventDelegate: context.coordinator)
        return chatController
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