//
//  VLConfig.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import Foundation

@objc public class VLConfig : NSObject {
    @objc public enum SCOPE : Int {
        case ROOM = 0
        case USER = 1
    }
    
    var clientId: String
    var userId: String?
    var userName: String?
    var userEmail: String?
    var userPhone: String?
    var isStaging: Bool = false
    var notificationToken: String? = nil
    private var customFields: [CustomField] = []
    
    @objc public init(clientId cid: String, userId uid: String?) {
        var userId = uid
        
        if uid == nil {
            userId = UUID().uuidString
        }
        
        clientId = cid
        self.userId = userId
    }
    
    @objc public convenience init(clientId cid: String) {
        let uid = UserDefaults.standard.string(forKey: "VERLOOP_USER_ID")
        
        if uid != nil {
            self.init(clientId: cid, userId: uid!)
        } else {
            self.init(clientId: cid, userId: UUID().uuidString)
        }
    }
    
    @objc public func setNotificationToken(notificationToken token: String?) {
        notificationToken = token
    }
    
    @objc public func setStaging(isStaging staging: Bool) {
        isStaging = staging
    }
    
    @objc public func setUserName(userName name: String?) {
        userName = name
    }
    
    @objc public func setUserEmail(userEmail email: String?) {
        userEmail = email
    }
    
    
    @objc public func setUserPhone(userPhone phone: String?) {
        userPhone = phone
    }
    
    @objc public func putCustomField(key: String, value: String, scope: SCOPE) {
        
        switch scope {
        case .USER:
            customFields.append(CustomField(key: key, value: value, scope: "user"))
        case .ROOM:
            customFields.append(CustomField(key: key, value: value, scope: "room"))
        }
    }
    
    @objc func getCustomFieldsJSON() -> String? {
        let ret = UserDefaults.standard.string(forKey: "VERLOOP_CUSTOM_FIELDS")
//        if ret != nil {
//            print(ret!)
//        }
        return ret
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(clientId, forKey: "VERLOOP_CLIENT_ID")
        defaults.set(userId, forKey: "VERLOOP_USER_ID")
        defaults.set(userName, forKey: "VERLOOP_USER_NAME")
        defaults.set(userEmail, forKey: "VERLOOP_USER_EMAIL")
        defaults.set(userPhone, forKey: "VERLOOP_USER_PHONE")
        defaults.set(isStaging, forKey: "VERLOOP_IS_STAGING")
        defaults.set(notificationToken, forKey: "VERLOOP_NOTIFICATION_TOKEN")
        
        var jsonDictionary: [String: Any] = [:]
        
        customFields.forEach { (field: VLConfig.CustomField) in
            let optionsJson: [String: String] = ["scope": "user"]
            
            let innerJson: [String: Any] = [
                "value": field.value,
                "options": optionsJson
            ]
            jsonDictionary[field.key] = innerJson
        }
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: [])
            let json = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            defaults.set(json, forKey: "VERLOOP_CUSTOM_FIELDS")
        } catch { print(error) }
        
    }
    
    static func getConfig() -> VLConfig {
        let defaults = UserDefaults.standard
        let config = VLConfig(clientId: defaults.string(forKey: "VERLOOP_CLIENT_ID")!, userId: defaults.string(forKey: "VERLOOP_USER_ID"))
        
        config.setStaging(isStaging: defaults.bool(forKey: "VERLOOP_IS_STAGING"))
        
        config.setNotificationToken(notificationToken: defaults.string(forKey: "VERLOOP_NOTIFICATION_TOKEN"))
        
        config.setUserName(userName: defaults.string(forKey: "VERLOOP_USER_NAME"))
        config.setUserEmail(userEmail: defaults.string(forKey: "VERLOOP_USER_EMAIL"))
        config.setUserPhone(userPhone: defaults.string(forKey: "VERLOOP_USER_PHONE"))
        
        
        return config
    }
    
    struct CustomField : Codable {
        public let key: String
        public let value: String
        public let scope: String
    }
}
