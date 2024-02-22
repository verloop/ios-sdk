//
//  VLResponseModals.swift
//  VerloopSDK
//
//  Created by Mujahid Ali on 22/02/2024.
//  Copyright © 2024 Verloop. All rights reserved.
//

import Foundation

struct VLClientInfoSchema : Codable {
    let botUser : BotUser?
    let title : String?
    let bgColor : String?
    let textColor : String?
    let triggers : [String]?
    let csatEnabled : Bool?
    let csatBypassEnabled : Bool?
    let csatType : String?
    let unreadMessages : Int?
    let inputValidation : Bool?
    let inputInvalidMessage : String?
    let displayQueuePosition : Bool?
    let queuePositionMessage : String?
    let livechatSettings : LivechatSettings?
}

struct BotUser : Codable {
    let _id : String?
    let name : String?
    let imageUrl : String?
    let entityId : String?
}

struct ColorPalette : Codable {
    let primary : String?
}

struct Header : Codable {
    let title : Title?
    let subtitle : Subtitle?
    let brandLogo : BrandLogo?
}

struct BrandLogo : Codable {
    let uRL : String?
}

struct LivechatSettings : Codable {
    let header : Header?
    let theme : Theme?
    let cSSRawString : String?
}

struct Subtitle : Codable {
    let heading : String?
    let position : String?
}

struct Theme : Codable {
    let colorPalette : ColorPalette?
}

struct Title : Codable {
    let heading : String?
    let position : String?
}
