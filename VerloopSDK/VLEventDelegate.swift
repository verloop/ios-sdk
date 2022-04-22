//
//  VLEventDelegate.swift
//  VerloopSDK
//
//  Created by sreedeep on 19/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import Foundation

@objc public protocol VLEventDelegate {
    
    @objc optional func onChatMaximized()
    @objc optional func onChatMinimized()
    @objc optional func onChatStarted()
    @objc optional func onChatEnded()
    @objc optional func onLogoutComplete()
    @objc optional func onWidgetLoaded()
    @objc optional func onIncomingMessage(_ message:Any)
    
}
