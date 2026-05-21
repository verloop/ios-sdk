//
//  TestChatManimized.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 25/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestChatMinimized: XCTestCase {
    private var _config:VLConfig!
    private var manager:VLWebViewManager!
    private var chatMinimizedExpecatation:XCTestExpectation?
    private var isChatMinimized = false
    
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        manager = VLWebViewManager.init(config: _config)
        manager._eventDelegate = self
    }

    func testChatMinimized() {
        chatMinimizedExpecatation = expectation(description: "Chat Minimized")
        self.manager.updateReadyState(true)
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            self.manager.closeWidget(hasInternet: true)
        }
        waitForExpectations(timeout: 15.0)
        XCTAssertTrue(isChatMinimized)
    }
}

extension TestChatMinimized:VLEventDelegate {
    func onChatMinimized() {
        chatMinimizedExpecatation?.fulfill()
        chatMinimizedExpecatation = nil
        isChatMinimized = true
    }
}
