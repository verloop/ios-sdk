//
//  TestClickListeners.swift
//  VerloopSDKTests
//
//  Created by Sreedeep on 26/04/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest

class TestClickListeners: XCTestCase {

    private let mockButtonClick = "{\"title\":\"\(TestConstants.testButtonTitle)\",\"type\":\"postback\",\"payload\":\"NA\"}"
    private let mockButtonClickNegative = "{\"title\":\"\",\"type\":\"postback\",\"payload\":\"NA\"}"
    
    private let mockClientInfo = "{\"title\":\"\(TestConstants.testClientName)\",\"bgColor\":\"#00000\",\"textColor\":\"#ffffff\"}"
    private let mockURLClick = "{\"title\":\"\(TestConstants.testButtonTitle)\",\"type\":\"web_url\",\"payload\":\"https://www.verloop.io\"}"
    private let mockURLClickNegative = "{\"title\":\"\(TestConstants.testButtonTitle)\",\"type\":\"\",\"payload\":\"https://www.verloop.io\"}"

    
    private var config:VLConfig!
    private var sdk:VerloopSDK!
    
    override func setUpWithError() throws {
        config = VLConfig.init(clientId: TestConstants.clientId)
        sdk = VerloopSDK.init(config: config)
    }

    func testButtonClick() {

        config.setButtonOnClickListener { title, type, payload in
            print("button click listener called")
            XCTAssertEqual(title, TestConstants.testButtonTitle)
        }
        sdk.jsCallback(message: mockButtonClick)
        config.setButtonOnClickListener { title, type, payload in
            print("button click listener called")
            XCTAssertEqual(title, "")
        }
        sdk.jsCallback(message: mockButtonClickNegative)

    }

    func testURLClick() {
        config.setUrlClickListener { url in
            print("URL click listener called")
            XCTAssertEqual(url ?? "", "https://www.verloop.io")
        }
        sdk.jsCallback(message: mockURLClick)

        config.setUrlClickListener { url in
            print("URL click listener called")
            XCTAssertEqual(url ?? "", "")
        }
        sdk.jsCallback(message: mockURLClickNegative)
        
        
    }
    
    func testHexColor() {
        let color = VerloopSDK.hexStringToUIColor(hex: "#000000")
        XCTAssertEqual(color, UIColor(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    
}
