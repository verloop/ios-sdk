//
//  ReferenceModels.swift
//  VerifyVerloop
//
//  Created by Sreedeep on 22/03/22.
//

import Foundation
import VerloopSDK

enum RowType:String {
    case ClientID
    case UserId
    case RecepieID
    case UserParams
    case customField
    case Department
    case clearDepartment
    case OpenWidget
    case CloseWidget
    case ButtonClickListener
    case URLClickListener
    case LoginWithUserID
    case Logout
    case Close
    case EnableNotification
}

enum TestSections:Int,CaseIterable {
    case Inputs = 0
    case Actions
}

struct RowModel {
    let rowType:RowType
    let isInputType:Bool
    let titleToBeShown:String
    var valueToBeshown:String
    var secondValueToBeshown:String = ""
    var keysToBeShown:String = ""
    var isMultiInputs = false
    var keyPlaceHolder = ""
    var valuePlaceHolder = ""
}

class ViewModel {
    
    private var defaults:[[RowModel]] = []
    private var mSDK:VerloopSDK?
    
    private var inputs:[RowModel] = [
        RowModel(rowType: .ClientID, isInputType: true, titleToBeShown: "Enter Client ID *", valueToBeshown: "",keyPlaceHolder: "Client ID (required)"),
        RowModel(rowType: .UserId, isInputType: true, titleToBeShown: "Enter user ID", valueToBeshown: "",keyPlaceHolder: "User ID"),
        RowModel(rowType: .RecepieID, isInputType: true, titleToBeShown: "Enter Recepie ID", valueToBeshown: "",keyPlaceHolder: "Recepie ID"),
        RowModel(rowType: .UserParams, isInputType: true, titleToBeShown: "Enter User params.", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key"),
        RowModel(rowType: .customField, isInputType: true, titleToBeShown: "Enter Custom Field", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key"),
        RowModel(rowType: .Department, isInputType: true, titleToBeShown: "Enter Department Name", valueToBeshown: "",keyPlaceHolder: "Depart name")
    ]
    
    private var actions:[RowModel] = [
        RowModel(rowType: .clearDepartment, isInputType: false, titleToBeShown: "Clear Department", valueToBeshown: "Tap to clear department"),
        RowModel(rowType: .ButtonClickListener, isInputType: false, titleToBeShown: "Tap to verify Buttton click listeners", valueToBeshown: "Button click listener"),
        RowModel(rowType: .URLClickListener, isInputType: false, titleToBeShown: "Tap to verify URL click listeners", valueToBeshown: "URL click listener"),
        RowModel(rowType: .LoginWithUserID, isInputType: false, titleToBeShown: "Tap to login with user ID", valueToBeshown: "login with User ID"),
        RowModel(rowType: .OpenWidget, isInputType: false, titleToBeShown: "OpenWidget to open the chat window", valueToBeshown: "Tap to open widget"),
        RowModel(rowType: .CloseWidget, isInputType: false, titleToBeShown: "close Widget(Added on the button title", valueToBeshown: "Tap to close widget"),
        RowModel(rowType: .Logout, isInputType: false, titleToBeShown: "Logging Out (First login and then try this scenario)", valueToBeshown: "Tap to log out"),
        RowModel(rowType: .Close, isInputType: false, titleToBeShown: "Close (will close the current conversation)", valueToBeshown: "Tap to close"),
        RowModel(rowType: .EnableNotification, isInputType: false, titleToBeShown: "Enable Notifications", valueToBeshown: "Tap to test notifications feature")
    ]
    
    init() {
//        defaults.append(inputs)
//        defaults.append(actions)
//        print("defaults \(defaults)")
        resetData()
    }
    
    private func resetData() {
        defaults.removeAll()
        defaults.append(inputs)
        defaults.append(actions)
    }
    
    func getNumberOfrowsToDisplayed(section:Int) -> Int {
        return defaults[section].count
    }
    
    func getModelAtIndex(_ index:IndexPath) -> RowModel {
        return defaults[index.section][index.row]
    }
    
    func didChangeModelInput(_ text:String,modelIndex:IndexPath,isSecondaryField:Bool) {
        if isSecondaryField {
            defaults[modelIndex.section][modelIndex.row].secondValueToBeshown = text
        } else {
            defaults[modelIndex.section][modelIndex.row].valueToBeshown = text
        }
    }
    
    func clearChatInputs() {
        
        resetData()
        mSDK?.clearLocalStorage()
    }
    
    func getNumberOfSections() -> Int {
        return TestSections.allCases.count
    }
    
    func getSectionHeight(_ section:TestSections) -> Float {
        return section == .Inputs ? 80.0 : 0
    }
    
    func getTitleForSection(section:TestSections) -> String {
        return section == .Inputs ? "Enter details in fields and tap Launch chat" : "Click on below button to open / close chat"
    }
    
    func getInputsConfig() -> VLConfig? {
        if(defaults.first?.first?.valueToBeshown ?? "").isEmpty {
            return nil
        }
        var config:VLConfig?
        for fieldInput in defaults.first ?? [] {
            if fieldInput.valueToBeshown.isEmpty {
               continue
            }
            switch fieldInput.rowType {
                case .ClientID:
                    config = VLConfig.init(clientId: fieldInput.valueToBeshown)
                case .UserId:
                    config?.setUserId(userId: fieldInput.valueToBeshown)
                case .RecepieID:
                    config?.setRecipeId(recipeId: fieldInput.valueToBeshown)
                case .Department:
                    config?.setDepartment(fieldInput.valueToBeshown)
                case .UserParams:
                    if !fieldInput.valueToBeshown.isEmpty,!fieldInput.secondValueToBeshown.isEmpty {
                        config?.setUserParam(key: fieldInput.valueToBeshown, value: fieldInput.secondValueToBeshown)
                    }
                case .customField:
                    if !fieldInput.valueToBeshown.isEmpty,!fieldInput.secondValueToBeshown.isEmpty {
                        config?.putCustomField(key: fieldInput.valueToBeshown, value: fieldInput.secondValueToBeshown, scope: .USER)
                    }
                default:break
            }
        }
        return config
    }
}

extension ViewModel {
    
    func showmessage(title:String,message:String,controller:UIViewController) {
        let alrt = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alrt.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        controller.present(alrt, animated: true, completion: nil)
    }
    
    private func createSDK(config:VLConfig) {
        mSDK = VerloopSDK(config: config)
    }
    
    private func getSDKController() -> UIViewController {
        return mSDK!.getNavController()
    }
    
    private func getUserIDClientID() -> (userID:String,clentID:String) {
        var userID = ""
        var clientID = ""
        for ip in defaults.first ?? [] {
            if ip.rowType == .UserId {
                userID = ip.valueToBeshown
            } else if ip.rowType == .ClientID {
                clientID = ip.valueToBeshown
            }
        }
        return (userID,clientID)
    }
    
    func launchChatOn(controller:UIViewController,config:VLConfig) {
        createSDK(config: config)
        controller.present(getSDKController(), animated: true, completion: nil)
    }
    class func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    func launchChatWithAction(indexPath:IndexPath,controller:UIViewController) {
        var type:RowType!
        if indexPath.row < defaults[indexPath.section].count {
            type = defaults[indexPath.section][indexPath.row].rowType
        } else {
            return
        }
        if type == .OpenWidget {
            guard let id = defaults.first?.first?.valueToBeshown, !id.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            launchChatOn(controller: controller, config: VLConfig.init(clientId: id))
        } else if type == .Logout {
            mSDK?.logout()
        } else if type == .CloseWidget {
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = VLConfig.init(clientId: details.clentID)
            config.setButtonOnClickListener { title, type, payload in
                self.mSDK?.closeWidget()

            }
            launchChatOn(controller: controller, config: config)
    
        } else if type == .EnableNotification {
            let details = getUserIDClientID()
//            let userID = details.userID
            let clientID = details.clentID
            let config = VLConfig.init(clientId: clientID)
//            let token = UserDefaults.standard.object(forKey: "Device_token")
////            let token = ViewModel.isKeyPresentInUserDefaults(key: "Device_token")
//            config.setNotificationToken(notificationToken: "bee3cddc4c9399c0106777be608e322fddfd0540a0e4506dc77dd5e8bd3898b2")
            if let token = UserDefaults.standard.value(forKey: "Device_token") as? String {
                config.setNotificationToken(notificationToken: token)
                launchChatOn(controller: controller, config: config)
            }
        
        } else if type == .Close {
            mSDK?.close()
        } else if type == .LoginWithUserID {
            let details = getUserIDClientID()
            let userID = details.userID
            let clientID = details.clentID
            
            guard !userID.isEmpty,!clientID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and User ID and try again", controller: controller)
                return
            }
            let config = VLConfig.init(clientId: clientID)
            config.setUserId(userId: userID)
            launchChatOn(controller: controller, config: config)
        } else if type == .ButtonClickListener {
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = VLConfig.init(clientId: details.clentID)
            config.setButtonOnClickListener { title, type, payload in
 
                self.showmessage(title: "Button click", message:  "Title \(title ?? "") \nType \(type ?? "")\nPayload \(payload ?? "")", controller: controller)
            }
            launchChatOn(controller: controller, config: config)
        } else if type == .URLClickListener {
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = VLConfig.init(clientId: details.clentID)
            config.setUrlClickListener { url in
              
                self.showmessage(title: "URL Click", message: "Url: \(url ?? "")", controller: controller)
            }
            launchChatOn(controller: controller, config: config)
        }
    }
}
