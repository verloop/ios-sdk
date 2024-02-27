//
//  VLConfig.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import Foundation
import WebKit

public typealias LiveChatButtonClickListener = (_ title : String?, _ type : String?, _ payload : String?)  -> Void
public typealias LiveChatUrlClickListener = (_ url : String?)  -> Void

@objc public class VLConfig : NSObject {
    
    struct CustomField : Codable {
        public let key: String
        public let value: String
        public let scope: String
    }
    
    struct UserParam {
        public let key: String
        public let value: String
    }
    
    enum UserParamType:String {
        case email
        case phone
        case name
    }
    enum APIMethods {
        case userId
        case userName
        case email
        case phoneNumber
        case recipe
        case department
        case userParams
        case customFields
        case clearDepartment
        case openWidget
        case closeWidget
        case close
        case widgetColor
    }
    //Scope for custom fields
    @objc public enum SCOPE : Int {
        case ROOM = 0
        case USER = 1
    }
   private var clientId: String
   private var userId: String?
   private var userName: String?
   private var userEmail: String?
   private var userPhone: String?
   private var department:String?
   private var isStaging: Bool = false
   private var notificationToken: String? = nil
   private var recipeId: String? = nil
   private var onButtonClicked: LiveChatButtonClickListener? = nil
   private var onUrlClicked: LiveChatUrlClickListener? = nil
   private var urlRedirection : Bool = true
   private var mEventChangeDelegate:VLEventDelegate?
   private var customFields: [CustomField] = []
   private var userParams: [UserParam] = []
   private var widgetColor:String?
   
   private var updatedConfigParams:[APIMethods] = []
   private var title = Constants.Literals.EMPTY_STRING
   private var bgColor: UIColor = .black
   private var textColor: UIColor = .white
    
    func isValidEmail(_ email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidNumber(_ number:String) -> Bool {
        let reg = "^[0-9]+$"
        let numPred = NSPredicate(format:"SELF MATCHES %@", reg)
        return numPred.evaluate(with: number)
    }
    
    @objc public init(clientId cid: String, userId uid: String?) {
        var userId = uid

        let uid = UserDefaults.standard.string(forKey: "VERLOOP_USER_ID")
        if uid == nil {
            userId = UUID().uuidString
        }
        clientId = cid
        self.userId = userId
        self.updatedConfigParams = []
        if let ud = userId,!ud.isEmpty {
            self.updatedConfigParams.append(.userId)
        }
    }

    @objc public convenience init(clientId cid: String) {
        let uid = UserDefaults.standard.string(forKey: "VERLOOP_USER_ID")
        if uid != nil {
            self.init(clientId: cid, userId: uid!)
        } else {
            self.init(clientId: cid, userId: UUID().uuidString)
        }
        self.updatedConfigParams = []
        if let ud = userId,!ud.hasEmptyValue() {
            self.updatedConfigParams.append(.userId)
        }
    }
    
    @objc public func setNotificationToken(notificationToken token: String?) {
        if !(token ?? "").hasEmptyValue() {
            notificationToken = token
        }
    }
    
    @objc public func setUserId(userId uid: String) {
        if !uid.hasEmptyValue() {
            userId = uid
            if !updatedConfigParams.contains(.userId),!uid.hasEmptyValue() {
                updatedConfigParams.append(.userId)
            }
        }
    }
    
    @objc public func setStaging(isStaging staging: Bool) {
        isStaging = staging
    }
    
    @objc public func setUserName(userName name: String?) {
        if let _name = name,!_name.hasEmptyValue() {
            setUserParam(key: UserParamType.name.rawValue, value: _name)
        }
    }
    
    @objc public func setUserEmail(userEmail email: String?) {
        if let _email = email,!_email.hasEmptyValue(),isValidEmail(_email) {
            setUserParam(key: UserParamType.email.rawValue, value: _email)
        }
    }
    
    @objc public func setUserPhone(userPhone phone: String?) {
        if let _phone = phone,!_phone.hasEmptyValue(),isValidNumber(_phone) {
            setUserParam(key: UserParamType.phone.rawValue, value: _phone)
        }
    }
    
    @objc public func setRecipeId(recipeId id: String?) {
        if !updatedConfigParams.contains(.recipe),!(id ?? "").hasEmptyValue() {
            recipeId = id
            updatedConfigParams.append(.recipe)
        }
    }
    
    @objc public func setUserParam(key:String,value:String) {
        if let param = UserParamType.init(rawValue: key),!key.hasEmptyValue(),!value.hasEmptyValue() {
            if param == .email,!isValidEmail(value) {
                return
            } else if param == .phone,!isValidNumber(value) {
                return
            }
            userParams.append(VLConfig.UserParam(key: param.rawValue, value: value))
            if !updatedConfigParams.contains(.userParams) {
                updatedConfigParams.append(.userParams)
            }
        }
    }

//    @objc public func setOnEventChangeListener(_ delegate:VLEventDelegate?) {
//        mEventChangeDelegate = delegate
//    }
    
    @objc public func setButtonOnClickListener(onButtonClicked buttonClicked: LiveChatButtonClickListener?) {
        onButtonClicked = buttonClicked
    }
    
    @objc public func setUrlClickListener(onUrlClicked urlClicked: LiveChatUrlClickListener?) {
        onUrlClicked = urlClicked
    }
    
    @objc public func setUrlRedirectionFlag(canRedirect flag: Bool){
        urlRedirection = flag
    }

    @objc public func putCustomField(key: String, value: String, scope: SCOPE) {
        if !key.hasEmptyValue(),!value.hasEmptyValue() {
            updatedConfigParams.append(.customFields)
            switch scope {
                case .USER:
                    customFields.append(CustomField(key: key, value: value, scope: "user"))
                case .ROOM:
                    customFields.append(CustomField(key: key, value: value, scope: "room"))
                default:
                    customFields.append(CustomField(key: key, value: value, scope: "room"))
            }
        }
    }
    
    @objc func getCustomFieldsJSON() -> String? {
        let ret = UserDefaults.standard.string(forKey: "VERLOOP_CUSTOM_FIELDS")
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
        defaults.set(recipeId, forKey: "VERLOOP_RECIPE_ID")
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

    func resetConfigParams() {
          print("resetConfigParams in vlconfig")
          userId = nil
          userName = nil
          userEmail = nil
          userPhone = nil
          notificationToken = nil
          recipeId = nil
          onButtonClicked = nil
          onUrlClicked = nil
          customFields.removeAll()
          userParams.removeAll()
          updatedConfigParams = []
      }

      func clear() {
          resetConfigParams()
      }
      
    func clearUserDetails(){
        
        userId = nil
        userName = nil
        userEmail = nil
        userPhone = nil
        customFields.removeAll()
        userParams.removeAll()

        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "VERLOOP_USER_ID")
        defaults.removeObject(forKey: "VERLOOP_USER_NAME")
        defaults.removeObject(forKey: "VERLOOP_USER_EMAIL")
        defaults.removeObject(forKey: "VERLOOP_USER_PHONE")
        defaults.removeObject(forKey: "VERLOOP_CUSTOM_FIELDS")
    //v1 Implementation
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: websiteDataTypes as! Set<String>, completionHandler: { (data) -> Void in
                for data_record in data {
                    NSLog(data_record.displayName);
                }
            })
            
            
            let date = NSDate(timeIntervalSince1970: 0)

            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
            
            
            
        } else {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"

            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
              print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
    //MARK: - This is updating the navigation bar properties like bgColor, textColor, and title
    func updateClientInitInfo(response: VLClientInfoSchema?) {
        
        if let title = response?.livechatSettings?.Header?.Title?.Heading {
            self.title = title
        } else {
            if let title = response?.title {
                self.title = title
            }
        }
        
        if let textColor = response?.livechatSettings?.Theme?.ColorPalette?.Primary {
            self.textColor = VerloopSDK.hexStringToUIColor(hex: textColor)
            self.bgColor = UIColor.white
        } else {
            if let textColor = response?.textColor {
                self.textColor = VerloopSDK.hexStringToUIColor(hex: textColor)
            }
            
            if let bgColor = response?.bgColor, !bgColor.isEmpty {
                self.bgColor = VerloopSDK.hexStringToUIColor(hex: bgColor)
            }
        }
    }
}

extension VLConfig {
    
    func getUserID() -> String? {
        return userId
    }
    func getClientID() -> String {
        return clientId
    }
    func getUsername() -> String? {
        for param in userParams {
            if param.key == UserParamType.name.rawValue {
                return param.value
            }
        }
        return nil
    }
    func getUserEmail() -> String? {
        for param in userParams {
            if param.key == UserParamType.email.rawValue {
                return param.value
            }
        }
        return nil
    }
    func getUserPhone() -> String? {
        for param in userParams {
            if param.key == UserParamType.phone.rawValue {
                return param.value
            }
        }
        return nil
    }
    func isStagingEnvironment() -> Bool {
        return isStaging
    }
    func getNotificationToken() -> String? {
        return notificationToken
    }
    func getRecipeId() -> String? {
        return recipeId
    }
    func getCustomFields() -> [CustomField] {
        return customFields
    }
    func getUserParams() -> [UserParam] {
        return userParams
    }
    func isURLRedirection() -> Bool {
        return urlRedirection
    }
    func getButtonClickListener() -> LiveChatButtonClickListener? {
        return onButtonClicked
    }
    func getURLClickListener() -> LiveChatUrlClickListener? {
        return onUrlClicked
    }
    func getUpdatedConfigParams() -> [APIMethods] {
        return updatedConfigParams
    }
    func getDepartment() -> String? {
        return self.department
    }
    
    var getNavTitle: String {
        return title
    }
    
    var getNavBgColor: UIColor {
        return bgColor
    }
    
    var getNavTextColor: UIColor {
        return textColor
    }
    
    func setNavTitle(title: String) {
        self.title = title
    }
    
    func setNavBgColor(bgColor: UIColor) {
        self.bgColor = bgColor
    }
    
    func setNavTextColor(textColor: UIColor) {
        self.textColor = textColor
    }
    
    var getLiveChatInitUrl: String {
        return Constants.VLUrls.getLiveChatInitEndpoints(clientId: getClientID(), 
                                                         envUrl: isStagingEnvironment() ? Constants.URL_STAGING : Constants.URL_PROD)
    }
}
