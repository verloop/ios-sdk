////
////  ConfigTestViewController.swift
////  VerifyVerloop
////
////  Created by Sreedeep on 17/03/22.
////
//
//import UIKit
//import VerloopSDK
//
////enum RowType:String {
////    case Defaults
////    case UserId
////    case RecepieID
////    case UserParams
////    case customField
////    case Department
////    case clearDepartment
////    case OpenWidget
////    case CloseWidget
////    case AddListeners
////    case LoginWithUserID
////    case Logout
////    case Close
////}
//
//class ConfigTestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
//
//    private let mTitles:[RowType] = [.Defaults,.UserId,.RecepieID,.UserParams,.customField,.Department,.clearDepartment,.OpenWidget,.CloseWidget,.AddListeners,.LoginWithUserID,.Logout,.Close]
//    private var mValues:[String] = []
//    private let defaultClientID = "sreedeep.dev"
//    private let userId = "Verloop123"
//    private let recepieID = "Sy3xTxzrJXX8XCeCT"
//    private let userParamNameKey = "email"
//    private let userParamNameValue = "test@verloop.io"
//    private let userParamPhoneKey = "phone"
//    private let userParamPhoneValue = "+919999911111"
//    private let customFieldKey = "testKey"
//    private let customFieldValue = "testValue"
//    private let department = "sales"
//    private var mSDK:VerloopSDK?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = "Verloop"
//        mValues = ["Client ID \(defaultClientID) ",userId,recepieID,"\(userParamNameKey):\(userParamNameValue) \(userParamPhoneKey):\(userParamPhoneValue)","\(customFieldKey):\(customFieldValue) scope:room",department,"Clears department","Opening widget","Close widget","All listeners","verloop123","",""]
//        // Do any additional setup after loading the view.
//    }
//    
//    private func createSDK(config:VLConfig) {
//        mSDK = VerloopSDK(config: config)
//    }
//    
//    private func getSDKController() -> UIViewController {
//        return mSDK!.getNavController()
//    }
//    
//    private func getDefaultConfig() -> VLConfig {
//        let config = VLConfig.init(clientId: defaultClientID)
//        return config
//    }
//    
//    private func openDefaultConfig() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func setUserId() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setUserId(userId: userId)
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//        
//    }
//    
//    private func setRecepie() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setRecipeId(recipeId: recepieID)
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func setUserParam() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setUserParam(key: userParamPhoneKey, value: userParamPhoneValue)
////        config.setUserParam(key: "email", value: "test@test.com")
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    private func setCustomfield() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.putCustomField(key: customFieldKey, value: customFieldValue, scope: .ROOM)
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func setdepartment() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setDepartment(department)
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func clearDepartment() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.clearDepartment()
//        createSDK(config: config)
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func openWidget() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setDepartment("IT")
//        createSDK(config: config)
//        mSDK?.openWidget(rootController: self)
////        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func closeWidget() {
////        mSDK?.closeWidget()
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setRecipeId(recipeId: recepieID)
//        createSDK(config: config)
////        config.setButtonOnClickListener {[weak self] title, type, payload in
////            print("button clicked \(title ?? "")")
////            self?.closeWidget()
////        }
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func addListeners() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setRecipeId(recipeId: recepieID)
//        createSDK(config: config)
//        config.setButtonOnClickListener {[weak self] title, type, payload in
////            print("button clicked \(title ?? "")")
//            self?.mSDK?.closeWidget()
//            self?.showAlert(message: "Title \(title ?? "") \nType \(type ?? "")\nPayload \(payload ?? "")", title: "Button Click")
//        }
//        config.setUrlClickListener { url in
//            print("url clicked \(url ?? "")")
//        }
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func loginWithUserID() {
//        let config = VLConfig.init(clientId: defaultClientID)
//        config.setUserId(userId: userId)
//        createSDK(config: config)
//        mSDK?.login(userId: "hello.dev")
//        self.present(getSDKController(), animated: true, completion: nil)
//    }
//    
//    private func logout() {
//        mSDK?.logout()
//    }
//    
//    private func closeChat() {
//        mSDK?.close()
//    }
//
//    private func showAlert(message:String,title:String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return mTitles.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "titleCell")
//        if cell == nil {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "titleCell")
//            cell?.textLabel?.text = mTitles[indexPath.row].rawValue
//        } else {
//            cell?.textLabel?.text = mTitles[indexPath.row].rawValue
//        }
//        cell?.detailTextLabel?.text = ""
////        if mTitles[indexPath.row] == .CloseWidget {
//            cell?.detailTextLabel?.text = mValues[indexPath.row]
////        }
//        return cell!
//    }
//
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch mTitles[indexPath.row] {
//            case .Defaults:
//                openDefaultConfig()
//            case .UserId:
//                setUserId()
//            case .UserParams:
//                setUserParam()
//            case .RecepieID:
//                setRecepie()
//            case .customField:
//                setCustomfield()
//            case .Department:
//                setdepartment()
//            case .clearDepartment:
//                clearDepartment()
//            case .OpenWidget:
//                openWidget()
//            case .CloseWidget:
//                closeWidget()
//            case .AddListeners:
//                addListeners()
//            case .LoginWithUserID:
//                loginWithUserID()
//            case .Logout:
//                logout()
//            case .Close:
//                closeChat()
//        }
//    }
//}
