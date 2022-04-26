//
//  TestWidgetClose.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 16/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestWidgetClose: XCTestCase {

    private var _config:VLConfig!
    private var _sdk:VerloopSDK!
    private var widgetClosedExpecatation:XCTestExpectation?
    private var isWidgetClosed = false
    
    override func setUpWithError() throws {
        _config = TestConstants.getDefaultConfig()
        _sdk = TestConstants.createSDKWithConfig(_config)
        _sdk.observeLiveChatEventsOn(vlEventDelegate: self)
    }

    override func tearDownWithError() throws {
        _config = nil
        _sdk = nil
    }

    func testCloseWidget() throws {
//        _sdk.logout()
        widgetClosedExpecatation = expectation(description: "Widget close expectation")
        DispatchQueue.main.asyncAfter(deadline: .now()+10.0) {
            self._sdk.manager.updateReadyState(true)
            self._sdk.closeWidget()
        }
        waitForExpectations(timeout: 25.0)
        XCTAssertTrue(isWidgetClosed)
    }
}

extension TestWidgetClose:VLEventDelegate {
    func onChatMinimized() {
        widgetClosedExpecatation?.fulfill()
        widgetClosedExpecatation = nil
        isWidgetClosed = true
    }   
}
