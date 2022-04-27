//
//  TestChatStarted.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 25/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestChatStarted: XCTestCase {

    private let chatStartMsg = "{\"src\":\"verloop\",\"fn\":\"callback\",\"args\":\"chat-started\"}"
    private var _config:VLConfig!
    private var manager:VLWebViewManager!
    private var chatStartedExpecatation:XCTestExpectation?
    private var isChatStarted = false
    
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        manager = VLWebViewManager.init(config: _config)
        manager._eventDelegate = self
    }
    
    func testChatStarted() {
        chatStartedExpecatation = expectation(description: "Chat Started")
        do {
            try manager.handleWebPostMessage(chatStartMsg)
        } catch {
            print("testChatStarted error \(error)")
        }
        waitForExpectations(timeout: 3.0)
        XCTAssertTrue(isChatStarted)
    }
}

extension TestChatStarted:VLEventDelegate {
    func onChatStarted() {
        print("test onChatStarted")
        chatStartedExpecatation?.fulfill()
        chatStartedExpecatation = nil
        isChatStarted = true
    }
}
