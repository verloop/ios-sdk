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
    let Primary : String?
}

struct Header : Codable {
    let Title : Title?
    let Subtitle : Subtitle?
    let BrandLogo : BrandLogo?
}

struct BrandLogo : Codable {
    let URL : String?
}

struct LivechatSettings : Codable {
    let Header : Header?
    let Theme : Theme?
    let CSSRawString : String?
}

struct Subtitle : Codable {
    let Heading : String?
    let Position : String?
}

struct Theme : Codable {
    let ColorPalette : ColorPalette?
}

struct Title : Codable {
    let Heading : String?
    let Position : String?
}
