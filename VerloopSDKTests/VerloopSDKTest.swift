//
//  VerloopSDKTest.swift
//  VerloopSDKTests
//
//  Created by Verloop on 21/02/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class VerloopSDKTest: XCTestCase {

    private var _config:VLConfig!
    private var _sdk:VerloopSDK!
    override func setUpWithError() throws {
        _config = VLConfig(clientId: TestConstants.clientId,userId: TestConstants.userId)
        _config.setUserEmail(userEmail: TestConstants.email)
        _config.setUserName(userName: TestConstants.name)
        _config.setUserPhone(userPhone: TestConstants.phone)
        _config.putCustomField(key: TestConstants.customField.keys.first ?? "", value: TestConstants.customField.values.first ?? "", scope: .USER)
        _config.setRecipeId(recipeId: TestConstants.recepie)
        _sdk = VerloopSDK.init(config: _config)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSDKConfig() {
        _sdk.clearConfig()
        XCTAssertTrue(_config.getUpdatedConfigParams().isEmpty)
    }


}
