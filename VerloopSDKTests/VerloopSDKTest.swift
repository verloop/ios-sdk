//
//  VerloopSDKTest.swift
//  VerloopSDKTests
//
//  Created by Verloop on 21/02/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest
import WebKit

class VerloopSDKTest: XCTestCase {

    private var _config:VLConfig!
    private var _sdk:VerloopSDK!
    private var verloopController:VLViewController?
    private var verloopWebManager:VLWebViewManager?
    private let expectation = XCTestExpectation(description: "WIdget Opened")
    private let logoutExpectation = XCTestExpectation(description: "Log out user")
    private let setUserIDComplete = XCTestExpectation(description: "Set userid complete")
    private let setUserParamComplete = XCTestExpectation(description: "Set user Param complete")
    private let buttonClickListener = XCTestExpectation(description: "Button Click listener complete")
    private let urlClickListener = XCTestExpectation(description: "URL Click listener complete")
    private let logoutsExpectation = XCTestExpectation(description: "URL Click listener complete")
    private let mockButtonClick = "{\"title\":\"\(TestConstants.testButtonTitle)\",\"type\":\"button\",\"payload\":\"NA\"}"
//    private let mockClientInfo = "{\"title\":\"\(TestConstants.testClientName)\",\"bgColor\":\"#00000\",\"textColor\":\"#ffffff\"}"
    private let mockURLClick = "{\"url\":\"\((TestConstants.testURL))\"}"
    
    override func setUpWithError() throws {
        _config = VLConfig(clientId: TestConstants.clientId,userId: TestConstants.userId)
        _config.setUserId(userId: TestConstants.userId)
        _config.setUserEmail(userEmail: TestConstants.email)
        _config.setUserName(userName: TestConstants.name)
        _config.setUserPhone(userPhone: TestConstants.phone)
        _config.putCustomField(key: TestConstants.customField.keys.first ?? "", value: TestConstants.customField.values.first ?? "", scope: .USER)
        _config.setRecipeId(recipeId: TestConstants.recepie)
        _sdk = VerloopSDK.init(config: _config)
        _sdk.observeLiveChatEventsOn(vlEventDelegate: self)
        verifyClickListener()
//        logOutUser()
        _sdk.jsCallback(message: mockButtonClick)
        _sdk.jsCallback(message: mockURLClick)
//        _sdk.jsCallback(message: mockClientInfo)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSDKConfig() {
        _sdk.clearConfig()
        XCTAssertTrue(!_config.getUpdatedConfigParams().isEmpty)
    }

    func testHexColor() {
        let color = VerloopSDK.hexStringToUIColor(hex: "#000000")
        XCTAssertEqual(color, UIColor(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    func testVerloopController() {
        let chatNavigationController = _sdk.getNavController()
        verloopController = (chatNavigationController.viewControllers.first as? VLViewController)
        XCTAssertNotNil(verloopController)
        verloopWebManager = verloopController?.webView
        XCTAssertNotNil(verloopWebManager)
        _sdk.observeLiveChatEventsOn(vlEventDelegate: self)
        verifyWebView()
        verifyCustomFieldsJSON()
//        logOutUser()
        
    }
    
    func verifyWebView() {
        verifyUserID()
        verifyUserParamComplete()
        verloopController?.webView?.startRoom()
        verloopController?.webView?.setConfig(config: _config)
    }
    
    func verifyUserID() {
        wait(for: [setUserIDComplete], timeout: 15.0)
    }
    
    func verifyUserParamComplete() {
        wait(for: [setUserParamComplete], timeout: 15.0)
        sleep(3)
//        logOutUser()
    }
    
    func logOutUser() {
        _sdk.logout()
        wait(for: [logoutsExpectation], timeout: 15.0)
    }
    
    func verifyLogoutCache() {
        let config = _sdk.getConfig()
        XCTAssertNil(config.getUsername())
        XCTAssertNil(config.getRecepieId())
    }
    
    func verifyCustomFieldsJSON() {
        if let json = _config.getCustomFieldsJSON(),let data = json.data(using: .utf8) {
            print("testCustomFieldsJSON \(json)")
            do {
                if let converted = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any] {
                    XCTAssertNotNil(converted["is_beauty"])
                }
            } catch {
                print("testCustomFieldsJSON error \(error)")
            }
        }
    }
    
    func verifyClickListener() {
        _config.setButtonOnClickListener { title, type, payload in
            XCTAssertEqual(title, TestConstants.testButtonTitle)
        }
        _config.setUrlClickListener { url in
            XCTAssertEqual(url, TestConstants.testURL)
        }
    }
    

}

extension VerloopSDKTest:VLEventDelegate {
    func didEventOccurOnLiveChat(_ event: VLEvent) {
        print("didEventOccurOnLiveChat \(event)")
        switch event {
        case .onButtonClick:
            break
        case .onURLClick:
            break
        case .onChatMaximized:
            break
        case .onChatMinimized:
            break
        case .onChatStarted:
            break
        case .onChatEnded:
            break
        case .onLogoutComplete:
            logoutExpectation.fulfill()
            verifyLogoutCache()
            break
        case .onWidgetLoaded:
            break
        case .onWidgetClosed:
            break
        case .setUserIdComplete:
            print("setUserIdComplete")
            setUserIDComplete.fulfill()
            break
        case .setUserParamComplete:
            setUserParamComplete.fulfill()
            break
        }
    }
    
    func testJSCB() {
        let string = "{\"src\":\"verloop\",\"fn\":\"callback\",\"args\":[\"button-clicked\"]}"
//        VerloopSDK.scriptCallback(message: string)
        let str = "{\"src\":\"vberloop\",\"fn\":\"callback\",\"args\":[\"url-clicked\"]}"
//        VerloopSDK.scriptCallback(message: str)
    }
}
