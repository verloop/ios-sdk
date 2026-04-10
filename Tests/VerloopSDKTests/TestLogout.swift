//
//  TestLogout.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 16/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestLogout: XCTestCase,VLEventDelegate {
    private var _config:VLConfig!
    private var _sdk:VerloopSDK!
    private let logoutMessage = "{\"src\":\"verloop\",\"fn\":\"closeWidget\",\"args\":\"logout\"}"
    private let logoutMessageNegative = "{\"src\":\"verloop\",\"fn\":\"closeWidget\",\"args\":\"\"}"
    
    private var manager:VLWebViewManager!
    var logoutExpecatation:XCTestExpectation!
    var isSuccessLogout = false
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        manager = VLWebViewManager.init(config: _config)
        manager._eventDelegate = self
    }

    func testLogout() throws {
        logoutExpecatation = expectation(description: "Logout did completed")
//        let expectation = expectation(description: "logout expectation")
        do {
            try manager.handleWebPostMessage(logoutMessage)
        } catch {
            print("testChatEnded error \(error)")
        }
        waitForExpectations(timeout: 3)
        XCTAssertTrue(isSuccessLogout)
        
        //negative
//        logoutExpecatation = expectation(description: "Logout did negative")
//        isSuccessLogout = false
//        manager.handleWebPostMessage(logoutMessageNegative)
//        waitForExpectations(timeout: 3)
//        XCTAssertFalse(isSuccessLogout)
    }
    
    func onLogoutComplete() {
        logoutExpecatation.fulfill()
        logoutExpecatation = nil
        isSuccessLogout = true
        print("test onLogoutComplete")
    }
}
