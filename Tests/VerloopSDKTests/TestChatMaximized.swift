//
//  TestChatMaximized.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 25/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestChatMaximized: XCTestCase {
    private var _config:VLConfig!
    private var manager:VLWebViewManager!
    private var chatMaximizedExpecatation:XCTestExpectation?
    private var isChatMaximized = false
    
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        manager = VLWebViewManager.init(config: _config)
        manager._eventDelegate = self
    }

    func testChatMaximized() {
        chatMaximizedExpecatation = expectation(description: "Chat Maximized")
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0) {
            self.manager.openWidget()
        }
        waitForExpectations(timeout: 25.0)
        XCTAssertTrue(isChatMaximized)
    }
}

extension TestChatMaximized:VLEventDelegate {
    func onChatMaximized() {
        print("test onChatMaximized")
        chatMaximizedExpecatation?.fulfill()
        chatMaximizedExpecatation = nil
        isChatMaximized = true
    }
}
 
