//
//  ReferenceModels.swift
//  VerifyVerloop
//
//  Created by Sreedeep on 22/03/22.
//

import Foundation
import VerloopSDK

//enum with different categories to be handled
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

//number of sections appears in tableview
enum TestSections:Int,CaseIterable {
    case Inputs = 0
    case Actions
}

//model for each row in tableview.
struct RowModel {
    let rowType:RowType
    let isInputType:Bool
    let titleToBeShown:String
    var valueToBeshown:String //value appears in the text field or button title
    var secondValueToBeshown:String = ""
    var keysToBeShown:String = ""
    var isMultiInputs = false
    var keyPlaceHolder = ""
    var valuePlaceHolder = ""
    var showRightAccessoryView = false
    var additionView = false
}

class ViewModel {
    
    private var defaults:[[RowModel]] = []
    private var mSDK:VerloopSDK?
    private var presentedSDKController:UIViewController?
    private var config:VLConfig?
    
    //default inputs to be shown in tableview 1st section
    private var inputs:[RowModel] = [
        RowModel(rowType: .ClientID, isInputType: true, titleToBeShown: "Enter Client ID *", valueToBeshown: "",keyPlaceHolder: "Client ID (required)",showRightAccessoryView:false,additionView:false),
        RowModel(rowType: .UserId, isInputType: true, titleToBeShown: "Enter user ID", valueToBeshown: "",keyPlaceHolder: "User ID",showRightAccessoryView:false,additionView:false),
        RowModel(rowType: .RecepieID, isInputType: true, titleToBeShown: "Enter Recepie ID", valueToBeshown: "",keyPlaceHolder: "Recepie ID",showRightAccessoryView:false,additionView:false),
        RowModel(rowType: .UserParams, isInputType: true, titleToBeShown: "Enter User params.", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key",showRightAccessoryView:true,additionView:true),
        RowModel(rowType: .customField, isInputType: true, titleToBeShown: "Enter Custom Field", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key",showRightAccessoryView:true,additionView:true)
    ]
    
    //default buttons with titles to be shown in tableview 2nd section
    private var actions:[RowModel] = [
        RowModel(rowType: .ButtonClickListener, isInputType: false, titleToBeShown: "Tap to verify Buttton click listeners", valueToBeshown: "Button click listener"),
        RowModel(rowType: .URLClickListener, isInputType: false, titleToBeShown: "Tap to verify URL click listeners", valueToBeshown: "URL click listener"),
        RowModel(rowType: .LoginWithUserID, isInputType: false, titleToBeShown: "Tap to login with user ID", valueToBeshown: "login with User ID"),
        RowModel(rowType: .OpenWidget, isInputType: false, titleToBeShown: "OpenWidget to open the chat window", valueToBeshown: "Tap to open widget"),
        RowModel(rowType: .CloseWidget, isInputType: false, titleToBeShown: "Launch this chat and observe our chat window closing when a button is pressed", valueToBeshown: "Tap to close widget"),
        RowModel(rowType: .Logout, isInputType: false, titleToBeShown: "Logging Out (First login and then try this scenario)", valueToBeshown: "Tap to log out"),
        RowModel(rowType: .Close, isInputType: false, titleToBeShown: "Close (will close the current conversation)", valueToBeshown: "Tap to close"),
        RowModel(rowType: .EnableNotification, isInputType: false, titleToBeShown: "Enable Notifications", valueToBeshown: "Tap to test notifications feature")
    ]
    
    init() {
        resetData()
    }
    
    //just reset all data back to defaults
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
    
    //on add icon
    
    func didSelectAddAtIndexPath(_ path:IndexPath,completion:(() -> Void)) {
        if defaults[path.section].count > path.row {
            if defaults[path.section][path.row].rowType == .UserParams {
                let blankParams = RowModel(rowType: .UserParams, isInputType: true, titleToBeShown: "Enter User params.", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key",showRightAccessoryView:true,additionView:false)
                defaults[path.section].insert(blankParams, at: path.row+1)
                completion()
            } else if defaults[path.section][path.row].rowType == .customField {
                let blankFields = RowModel(rowType: .customField, isInputType: true, titleToBeShown: "Enter Custom Field", valueToBeshown: "",isMultiInputs:true,keyPlaceHolder:"Name of Key",valuePlaceHolder:"Value of key",showRightAccessoryView:true,additionView:false)
                defaults[path.section].insert(blankFields, at: path.row+1)
                completion()
            }
        }
    }
    
    func didSelectRemoveAtIndexpath(_ path:IndexPath,completion:(() -> Void)) {
        if defaults[path.section].count > path.row {
            if defaults[path.section][path.row].rowType == .UserParams {
                defaults[path.section].remove(at: path.row)
                completion()
            } else if defaults[path.section][path.row].rowType == .customField {
                defaults[path.section].remove(at: path.row)
                completion()
            }
        }
        
    }
    
    
    //reset the data of data source
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
    
    
    //following method iterate over the defaults array data source and returns the vlconfig object by setting all the data filled on 1st setion of tableview .
    func getInputsConfig() -> VLConfig? {
        if(defaults.first?.first?.valueToBeshown ?? "").isEmpty {
            return nil
        }
        
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
                break
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
    //helper method to show alert
    func showmessage(title:String,message:String,controller:UIViewController) {
        let alrt = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alrt.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        controller.present(alrt, animated: true, completion: nil)
    }
    //helper method to create verloopsdk
    private func createSDK(config:VLConfig) {
        mSDK = VerloopSDK(config: config)
        mSDK?.observeLiveChatEventsOn(vlEventDelegate: self)
    }
    
    //returns the verloop chat appears controller
    private func getSDKController() -> UIViewController {
        let cntrl = mSDK!.getNavController()
        presentedSDKController = cntrl
        return cntrl
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
    
    private func getRecepieiD() -> String {
        for ip in defaults.first ?? [] {
            if ip.rowType == .RecepieID {
                return ip.valueToBeshown
            }
        }
        return ""
    }
    
    //called when click on "launch chat" button in tableview section 1
    func launchChatOn(controller:UIViewController,config:VLConfig) {
        createSDK(config: config)
        controller.present(getSDKController(), animated: true, completion: nil)
    }
    class func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    //calls when click on any of the button which appears in the 2nd section of the tableview
    //all following methods need client Id as required input field.
    func launchChatWithAction(indexPath:IndexPath,controller:UIViewController) {
        var type:RowType!
        if indexPath.row < defaults[indexPath.section].count {
            type = defaults[indexPath.section][indexPath.row].rowType
        } else {
            return
        }
        if type == .OpenWidget { //open chat with default client id
            guard let id = defaults.first?.first?.valueToBeshown, !id.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            
            launchChatOn(controller: controller, config: getInputsConfig()!)
        } else if type == .Logout { // log out current session of verloop
            mSDK?.logout()
        } else if type == .CloseWidget { // closes the widget currently shown in screen i.e verloop chat screen
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = getInputsConfig()!
            config.setButtonOnClickListener { title, type, payload in
                self.mSDK?.closeWidget()

            }
            launchChatOn(controller: controller, config: config)
    
        } else if type == .EnableNotification { // calls when push notification enable button is clicked
            let details = getUserIDClientID()
            let clientID = details.clentID
            guard !clientID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = getInputsConfig()!
            if let token = UserDefaults.standard.value(forKey: "Device_token") as? String {
                config.setNotificationToken(notificationToken: token)
                launchChatOn(controller: controller, config: config)
            }
        
        } else if type == .Close { // closes the chat session
            mSDK?.close()
        } else if type == .LoginWithUserID { //open verloop chat with user ID entered in user id field
            let details = getUserIDClientID()
            let userID = details.userID
            let clientID = details.clentID
            
            guard !userID.isEmpty,!clientID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and User ID and try again", controller: controller)
                return
            }
            let config = getInputsConfig()!
            config.setUserId(userId: userID)
            launchChatOn(controller: controller, config: config)
        } else if type == .ButtonClickListener { // calls when click on any of the button whcih appears on the verloop chat web view DOM.
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = getInputsConfig()!
            let recepie = self.getRecepieiD()
            if !recepie.isEmpty {
                config.setRecipeId(recipeId: recepie)
            }
            config.setButtonOnClickListener {[weak self] title, type, payload in
                print("button click listenr called")
                
                if let presented = self?.presentedSDKController {
                    self?.showmessage(title: "Button click", message:  "Clicked on button with Title: \(title ?? "")", controller: presented)
                }
            }
            launchChatOn(controller: controller, config: config)
        } else if type == .URLClickListener { // calls when click on any of the URL whcih appears on the verloop chat web view DOM.
            let details = getUserIDClientID()
            guard !details.clentID.isEmpty else {
                showmessage(title: "Error", message: "Please enter Client ID and try again", controller: controller)
                return
            }
            let config = getInputsConfig()!

            config.setUrlRedirectionFlag(canRedirect: false)
      
            config.setUrlClickListener {[weak self] url in
                print("URL click listener called")
                
                if let presented = self?.presentedSDKController {
                    self?.showmessage(title: "URL Click", message: "Clicked on Url with link : \(url ?? "")", controller: presented)
                }
                
            }
            launchChatOn(controller: controller, config: config)
        }
    }
}

extension ViewModel:VLEventDelegate {
    func onChatMaximized() {
        print("ref onChatMaximized")
    }
    func onChatMinimized() {
        print("ref onChatMinimized")
    }
    func onChatStarted() {
        print("ref onChatStarted")
    }
    func onChatEnded() {
        print("ref onChatEnded")
    }
    func onLogoutComplete() {
        print("ref onLogoutComplete")
    }
    func onWidgetLoaded() {
        print("ref onWidgetLoaded")
    }
    func onIncomingMessage(_ message:Any) {
        print("ref onIncomingMessage \(message)")
    }
    
}

