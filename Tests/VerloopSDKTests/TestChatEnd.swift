//
//  TestChatEnd.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 25/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestChatEnd: XCTestCase {
    private var _config:VLConfig!
    private let chatEndmessage = "{\"src\":\"verloop\",\"fn\":\"callback\",\"args\":\"chat-ended\"}"
    private var manager:VLWebViewManager!
    private var chatEndedExpecatation:XCTestExpectation?
    private var isChatEnded = false
    
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        manager = VLWebViewManager.init(config: _config)
        manager._eventDelegate = self
    }

    func testChatEnded() {
        chatEndedExpecatation = expectation(description: "Chat End Expectation")
        do {
            try manager.handleWebPostMessage(chatEndmessage)
        } catch {
            print("testChatEnded error \(error)")
        }
        waitForExpectations(timeout: 3.0)
        XCTAssertTrue(isChatEnded)
    }
}

extension TestChatEnd:VLEventDelegate {
    func onChatEnded() {
        print("---> onChatEnded")
        chatEndedExpecatation?.fulfill()
        chatEndedExpecatation = nil
        isChatEnded = true
    }
}
