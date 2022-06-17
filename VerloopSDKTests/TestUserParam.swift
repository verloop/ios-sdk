//
//  TestUserParam.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 16/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

//class TestUserParam: XCTestCase {
//    
//    private var _config:VLConfig!
//    private var _sdk:VerloopSDK!
//    private let userParamSetExpectation = XCTestExpectation(description: "User Param set completed")
//    private let recipeSetExpectation = XCTestExpectation(description: "recipe set completed")
//    
//    override func setUpWithError() throws {
//        _config = TestConstants.getUserParamConfig()
//        _sdk = TestConstants.createSDKWithConfig(_config)
//        _sdk.observeLiveChatEventsOn(vlEventDelegate: self)
//    }
//
//    override func tearDownWithError() throws {
//        _config = nil
//        _sdk = nil
//    }
//
//    func testSetuserParam() throws {
//        wait(for: [userParamSetExpectation], timeout: 15.0)
//    }
//}
//
//extension TestUserParam:VLEventDelegate {
//    func didReceiveEventSetUserparamCompleted(_ message: Any) {
//        userParamSetExpectation.fulfill()
//    }
//    
//}
