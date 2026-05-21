//
//  VLEventDelegate.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 01/02/22..
//

import Foundation

struct VLMessage:Codable {
    let message:String?
}

enum VLEvent {
    case onButtonClick
    case onChatMaximized
    case onChatMinimized
    case onChatStarted
    case onChatEnded
    case onLogoutComplete
    case onWidgetLoaded
    case onIncomingMessage(_ message:VLMessage)
}

protocol VLEventDelegate {
    func didEventOccurOnLiveChat(_ event:VLEvent)
}
