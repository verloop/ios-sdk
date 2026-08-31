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
        return chatController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
