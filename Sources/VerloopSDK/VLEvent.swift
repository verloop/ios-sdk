//
//  VLEventDelegate.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 01/02/22..
//

import Foundation

@objc public class VLMessage:NSObject,Codable {
    let message:String?
}

//struct ArgsPayload: Codable {
//    let args: [Args]?
//    let src:String?
//    let fn:FunctionType?
//}
//
//struct Args: Codable {
//    let url:String?
//}

struct ExpectedEventPayload:Codable {
    let src:String?
    let title:String?
    let type:MessageType?
    let fn:FunctionType?
//    let payload:ExpectedPayload?
    struct ExpectedPayload:Codable {
        let value:String?
        let type:String?
    }
}

struct ExpectedEvent:Codable {
    let url:String?
}

internal enum FunctionType:String,Codable {
    case FunctionSetUserIdComplete = "setUserIdComplete"
    case FunctionSetUserParamComplete = "setUserParamComplete"
    case FunctionCallBack = "callback"
    case FunctionOnRoomReady = "roomReady"
    case FunctionReady = "ready"
    case FunctionCloseWidget = "closeWidget"
    case FunctionCloseComplete = "closeComplete"
    case FunctionChatMaximized = "chat-maximized"
    case FunctionChatMinimized = "chat-minimized"
    case FunctionChatStarted = "chat-started"
    case FunctionChatEnded = "chat-ended"
    case FunctionLogOutCompleted = "logout"
    case FunctionChatMessageReceived = "agent-message-received"
//    case FunctionChatDownloadClicked = "downloadClicked"
}

enum MessageType:String,Codable {
    case MessageButtonClick = "postback"
    case MessageURLClick = "web_url"
}

@objc public enum VLEvent:Int,RawRepresentable {
    case onButtonClick = 0
    case onURLClick
    case onChatMaximized
    case onChatMinimized
    case onChatStarted
    case onChatEnded
    case onLogoutComplete
    case onWidgetLoaded
    case onWidgetClosed
    case setUserIdComplete
    case setUserParamComplete
}
