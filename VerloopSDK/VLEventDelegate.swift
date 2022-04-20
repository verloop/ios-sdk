//
//  VLEventDelegate.swift
//  VerloopSDK
//
//  Created by sreedeep on 19/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import Foundation

//Public callback apis
@objc public protocol VLEventDelegate {
    
    @objc optional func onChatMaximized(_ message:Any)
    @objc optional func onChatMinimized(_ message:Any)
    @objc optional func onChatStarted(_ message:Any)
    @objc optional func onChatEnded(_ message:Any)
    @objc optional func onLogoutComplete(_ message:Any)
    @objc optional func onWidgetLoaded(_ message:Any)
    @objc optional func onIncomingMessage(_ message:Any)
    
}
