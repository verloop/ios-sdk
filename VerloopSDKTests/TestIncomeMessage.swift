//
//  TestIncomeMessage.swift
//  VerloopSDKTests
//
//  Created by sreedeep on 19/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestIncomeMessage: XCTestCase,VLEventDelegate {
    private let userMsgExample = "{\"src\":\"verloop\",\"fn\":\"callback\",\"args\":[\"agent-message-received\",{\"message\":{\"_id\":\"GL9v5A8GfvKfXE3Nd01650387023910661794\",\"rid\":\"GL9v5A8GfvKfXE3Nd\",\"status\":2,\"_seq\":0,\"ts\":\"2022-04-19T16:50:24.062Z\",\"u\":{\"entityId\":\"verloop_bot\",\"name\":\"\",\"imageUrl\":\"\"},\"msg\":\"Hi,Im Bottie\",\"inputDisabled\":false,\"BlockInfo\":{\"Id\":\"egcdBcyLshjB83Nyn\",\"Name\":\"Welcome\",\"Goals\":[]},\"quick_replied\":false}}]}"
    
    private let userMsgExampleNegative = "{\"src\":\"helloverloop\",\"fn\":\"callback\",\"args\":[\"agent-message-received\",{\"message\":{\"_id\":\"GL9v5A8GfvKfXE3Nd01650387023910661794\",\"rid\":\"GL9v5A8GfvKfXE3Nd\",\"status\":2,\"_seq\":0,\"ts\":\"2022-04-19T16:50:24.062Z\",\"u\":{\"entityId\":\"verloop_bot\",\"name\":\"\",\"imageUrl\":\"\"},\"msg\":\"Hi,Im Bottie\",\"inputDisabled\":false,\"BlockInfo\":{\"Id\":\"egcdBcyLshjB83Nyn\",\"Name\":\"Welcome\",\"Goals\":[]},\"quick_replied\":false}}]}"
    
//    let sdk = VerloopSDK(config: VLConfig.init(clientId: TestConstants.clientId))
    private var incomeMessageExpectaion:XCTestExpectation?

    private var manager:VLWebViewManager!
    private var isMessageReceived = false
    private var isNegativeMessageReceived = false
    
    override func setUpWithError() throws {
        let config = VLConfig.init(clientId: TestConstants.clientId)
        manager = VLWebViewManager.init(config: config)
        manager._eventDelegate = self
    }
    
    func testIncomeMessage() {
        incomeMessageExpectaion = expectation(description: "Expectation Income message")
        do {
            try manager.handleWebPostMessage(userMsgExample)
        } catch {
            print("testIncomeMessage error \(error)")
        }
        waitForExpectations(timeout: 3.0)
        XCTAssertTrue(isMessageReceived)
        
    }
    
    func testNegativeIncomeMessage() {
//        incomeMessageExpectaionNegative = expectation(description: "Expectation Income message negative")
//        XCTAssertThrowsError(try manager.handleWebPostMessage(userMsgExampleNegative))
        XCTAssertThrowsError(try manager.handleWebPostMessage(userMsgExampleNegative))
        
//        do {
//            try manager.handleWebPostMessage(userMsgExampleNegative)
//        } catch {
//            print("testIncomeMessage error \(error)")
//            incomeMessageExpectaion?.fulfill()
//            incomeMessageExpectaion = nil
//            isMessageReceived = false
//        }
//        waitForExpectations(timeout: 3.0)
//        XCTAssertTrue(isMessageReceived)
    }
    
    func onIncomingMessage(_ message: Any) {
        print("message received test case")
        incomeMessageExpectaion?.fulfill()
        incomeMessageExpectaion = nil
        isMessageReceived = true
//        XCTAssert((message as! String) == "Hi,Im Bottie")
    }
}
