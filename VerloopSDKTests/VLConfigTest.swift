//
//  VLConfigTest.swift
//  VerloopSDKTests
//
//  Created by Sreedeep on 21/02/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import XCTest
import VerloopSDK

class VLConfigTest: XCTestCase {
    private var _config:VLConfig!
    override func setUpWithError() throws {
        _config = VLConfig(clientId: TestConstants.clientId,userId: TestConstants.userId)
        _config.setUserId(userId: TestConstants.userId)
        _config.setUserEmail(userEmail: TestConstants.email)
        _config.setUserName(userName: TestConstants.name)
        _config.setUserPhone(userPhone: TestConstants.phone)
        _config.putCustomField(key: TestConstants.customField.keys.first ?? "", value: TestConstants.customField.values.first ?? "", scope: .USER)
//        _config.setDepartment(TestConstants.department)
        _config.setRecipeId(recipeId: TestConstants.recepie)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        _config.clearUserDetails()
    }

    
    func testDefaultConfiguration() {
        XCTAssertEqual(_config.getClientID(), TestConstants.clientId)
        XCTAssertEqual(_config.getUserID(), TestConstants.userId)
        
        _config.setUserId(userId: " ")
        XCTAssertNotEqual(_config.getUserID() ?? "", "")
    }
    
    func testUserParams() {
        XCTAssertEqual(_config.getUserEmail(), TestConstants.email)
        XCTAssertEqual(_config.getUsername(), TestConstants.name)
        XCTAssertEqual(_config.getUserPhone(), TestConstants.phone)
        
        _config.setUserEmail(userEmail: nil)
        _config.setUserPhone(userPhone: nil)
        _config.setUserName(userName: nil)
        
        
        XCTAssertNotNil(_config.getUserEmail())
        XCTAssertNotNil(_config.getUserPhone())
        XCTAssertNotNil(_config.getUsername())
        
        _config.setUserEmail(userEmail: "inValidEmail@")
        _config.setUserPhone(userPhone: "invalidPhone87")
        
        XCTAssertNotNil(_config.getUserEmail())
        XCTAssertNotNil(_config.getUserPhone())
    }
    
    func testCustomFiels() {
        let customField = _config.getCustomFields()
        XCTAssertTrue(!customField.isEmpty)
        if let first = customField.first {
            XCTAssertTrue(first.value == TestConstants.customField.values.first)
        }
        _config.putCustomField(key: TestConstants.customField.keys.first ?? "", value: "", scope: .ROOM)
        for field in _config.getCustomFields() {
            if field.key == TestConstants.customField.keys.first ?? "" {
                XCTAssertNotEqual(field.value, "")
            }
        }
    }
    
    func testEmailValidation() {
        XCTAssertTrue(_config.isValidEmail(TestConstants.email))
        XCTAssertFalse(_config.isValidEmail("helloIndia"))
    }
    
    func testNumberValidation() {
        XCTAssertTrue(_config.isValidNumber(TestConstants.phone))
        XCTAssertFalse(_config.isValidNumber("a432747h7"))
    }
    
    func  testDepartment() {
//        XCTAssertEqual(_config.getDepartment(), TestConstants.department)
////        _config.clearDepartment()
//        XCTAssertNil(_config.getDepartment())
    }
    
    func testRecepie() {
        XCTAssertEqual(_config.getRecepieId() ?? "", TestConstants.recepie)
        _config.setRecipeId(recipeId: nil)
        XCTAssertNotNil(_config.getRecepieId())
    }
    
    func testValidateConfigParams() {
        let configParams = _config.getUpdatedConfigParams()
        XCTAssertTrue(configParams.contains(.userParams))
        XCTAssertTrue(configParams.contains(.customFields))
    }
}
