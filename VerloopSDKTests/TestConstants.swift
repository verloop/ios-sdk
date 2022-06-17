//
//  TestConstants.swift
//  VerloopSDKTests
//
//  Created by Verloop on 19/02/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import Foundation
import VerloopSDK

struct TestConstants {
    static let clientId = "sreedeep.dev"
    static let userId = "12345"
    static let email = "sreedeep.dev@gmail.com"
    static let phone = "78353421312"
    static let name = "sreedeep"
    static let recipe = "Sy3xTxzrJXX8XCeCT"
    static let customField:[String:String] = ["is_beauty":"true"]
    static let testURL = "https://www.verloop.io"
    static let testButtonTitle = "VButton"
    static let testClientName = "Verloop"
    static let department = "IT"
    
    static func createSDKWithConfig(_ config:VLConfig) ->VerloopSDK {
        return VerloopSDK.init(config: config)
    }
    
    static func getDefaultConfig() -> VLConfig {
        return VLConfig.init(clientId: clientId)
    }
    
    static func getUserIdconfig() -> VLConfig {
        let config = VLConfig.init(clientId: clientId)
        config.setUserId(userId: userId)
        return config
    }
    
    static func getUserParamConfig() -> VLConfig {
        let config = VLConfig.init(clientId: clientId)
        config.setUserEmail(userEmail: email)
        config.setUserPhone(userPhone: phone)
        config.setUserName(userName: name)
        return config
    }
    
    static func getRecipeConfig() -> VLConfig {
        let config = VLConfig.init(clientId: clientId)
        config.setRecipeId(recipeId: recipe)
        return config
    }
    
    static func getCustomFieldConfig() -> VLConfig {
        let config = VLConfig.init(clientId: clientId)
        config.putCustomField(key: customField.keys.first!, value: customField.values.first!, scope: .ROOM)
        return config
    }
    
}
