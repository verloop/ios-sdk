////
////  TestUserId.swift
////  VerloopSDKTests
////
////  Created by sreedeep on 16/04/22.
////  Copyright © 2022 Verloop. All rights reserved.
////
//
//import XCTest
//import VerloopSDK
//
//class TestUserId: XCTestCase {
//    private var _config:VLConfig!
//    private var _sdk:VerloopSDK!
//    private let setUserIDComplete = XCTestExpectation(description: "Set userid complete")
//    private let chartStartedComplete = XCTestExpectation(description: "Chart Started Event Occured")
//    private let chartMaximizedComplete = XCTestExpectation(description: "Chart Maximized Event Occured")
//    private let chartMessageReceivedComplete = XCTestExpectation(description: "Chart Message Received Occured")
//
//
//    override func setUpWithError() throws {
//        _config = TestConstants.getUserIdconfig()
//        _sdk = TestConstants.createSDKWithConfig(_config)
//        _sdk.observeLiveChatEventsOn(vlEventDelegate: self)
//    }
//
//    override func tearDownWithError() throws {
//        _config = nil
//        _sdk = nil
//    }
//
//    func testUserIdAndBasicChatEventsValidate() {
//        wait(for: [setUserIDComplete,chartStartedComplete], timeout: 20.0)
//    }
//}
//
//extension TestUserId:VLEventDelegate {
//    func didReceiveEventSetUserIdCompleted(_ message: Any) {
//        setUserIDComplete.fulfill()
//    }
//
//    func didReceiveEventChatStarted(_ message: Any) {
//        chartStartedComplete.fulfill()
//    }
//
////    func didReceiveEventChatMaximized(_ message: Any) {
////        chartMaximizedComplete.fulfill()
////    }
////    func didReceiveEventChatMessageReceived(_ message: Any) {
////        chartMessageReceivedComplete.fulfill()
////    }
//}
