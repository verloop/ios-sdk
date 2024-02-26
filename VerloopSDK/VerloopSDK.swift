//
//  Verloop.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import WebKit
import UIKit
import Foundation

@objc open class VerloopSDK: NSObject, VLJSInterface {
    private var config: VLConfig
    var manager: VLWebViewManager!
    private var verloopController: VLViewController? = nil
    private var verloopNavigationController: UINavigationController? = nil

    var reachability: Reachability?
    var lostNetworkConnection = false
    @objc public init(config vlConfig: VLConfig) {
        config = vlConfig
        //Storing config params in user defaults
        config.save()
        super.init()
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)
        //Part of network reachability
        startHost(host: "verloop.io")
        getNavigationInfo()
    }
    
    deinit {
        verloopNavigationController = nil
        verloopController = nil
        config.resetConfigParams()
        stopNotifier()
    }
    
    @objc public func openWidget(rootController:UIViewController) {
        
        verloopNavigationController = getNavController()
        
        rootController.present(verloopNavigationController!, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {[weak self] in
                self?.manager.openWidget()
            }
        }
    }
    
    @objc public func closeWidget() {
        onChatClose {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {[weak self] in
                let hasNetwork = !((self?.reachability?.connection == .unavailable) )
                self?.manager.closeWidget(hasInternet: hasNetwork)
            }
        }
    }
    
    @objc public func close() {
        self.manager.close()
    }
    
    @objc public func observeLiveChatEventsOn(vlEventDelegate delegate:VLEventDelegate) {
        if manager != nil {
            manager.addEventChangeDelegate(delegate)
        }
    }
    
    @objc public func updateConfig(config vlConfig: VLConfig){
        config = vlConfig
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func login(){
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func login(userId uid: String){
        config.setUserId(userId: uid)
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func logout() {
        manager.logoutSession()
        clearConfig()
        config.clearUserDetails()
    }
    
    @objc public func clearConfig(){
        config.clear()
        manager.clearConfig(config: config)
        self.config = VLConfig(clientId: "")
        self.clearLocalStorage()
    }
    @objc public func clearLocalStorage(){
        manager.clearLocalStorageVistorToken()

    }
    public func getConfig() -> VLConfig {
        return config
    }
    
    @objc public func getNavController() -> UINavigationController {
            if verloopNavigationController != nil {

                return verloopNavigationController!

            }

            verloopController = VLViewController.init(webView: manager)

            verloopController!.title = config.getNavTitle

            verloopController!.setSDK(verloopSDK: self)

            verloopNavigationController = VLNavViewController.init(rootViewController: verloopController!)

            verloopNavigationController?.navigationItem.leftItemsSupplementBackButton = true

            verloopNavigationController?.navigationItem.hidesBackButton = false

            verloopNavigationController?.navigationItem.backBarButtonItem?.isEnabled = true

            verloopNavigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

            verloopNavigationController?.hidesBarsOnSwipe = false

            verloopNavigationController?.view.backgroundColor = .white

            verloopNavigationController?.navigationBar.barTintColor = UIColor.white

            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

            UINavigationBar.appearance().shadowImage = UIImage()

            UINavigationBar.appearance().isTranslucent = true

            verloopNavigationController?.modalPresentationStyle = .fullScreen

            return verloopNavigationController!

        }
    
    //called when client information such as color cod eof the bar and title to be displayed on bar received from the live chat script
    
    func refreshClientInfo() {
        
        verloopController?.title = config.getNavTitle

        verloopNavigationController?.navigationBar.backgroundColor = config.getNavBgColor

        verloopNavigationController?.navigationBar.barTintColor = config.getNavBgColor

        verloopNavigationController?.navigationBar.isTranslucent = false


        // TODO: In VLViewController, the leftBarButtonItem is set on controller's navigationItem and here it was being set on verloopNavigationController's navigationItem that was creating issue and leftBarItem's tint color was nil

        verloopController?.navigationItem.leftBarButtonItem?.tintColor = config.getNavTextColor

        verloopNavigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: config.getNavTextColor]

    }

    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.white
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //This method executes as part of the n/w state changes and if any n/w inactive tasks to be processed then web view manager make respective functions.
    func refreshwebViewOnNetworkReconnection() {
        manager.executeNetworkChangeConfigurations()
    }

    //following is a delegate method of JsDelegate which is responsible for handling back call backs to the client app for
    //button clicks
    //url clicks
    //where as 'ready' call back is used to identify the color code of the navigation bar and title
    //below method executes when user made a selection on the webview for links / buttons
    func jsCallback(message: Any) {
       let str = message as! String
       let data = str.data(using: String.Encoding.utf8)!
       do {
            let _ =  try JSONDecoder().decode(ClientInfo.self, from: data)
           //We are no longer updating the navigation bar from this location; instead, we are updating it from the getNavigationInfo() method.
//            title = clientInfo.title
//            bgColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.bgColor)
//            textColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.textColor)
//            refreshClientInfo()
            verloopController?.dismissLoader()
            manager.updateReadyState(true)
       }catch {
           print("Problem retreiving client Info")
       }
       do {
            let buttonInfo =  try JSONDecoder().decode(OnButtonClick.self, from: data)
            let title = buttonInfo.title
            let type = buttonInfo.type
            let payload = buttonInfo.payload
            config.getButtonClickListener()?(title,type, payload)
  
       }catch {
           print("Problem retreiving button Info")
       }
       do {
          let urlInfo =  try JSONDecoder().decode(OnURLClick.self, from: data)
          let url = urlInfo.url
          config.getURLClickListener()?(url)
      }catch {
          print("Problem retreiving url Info")
      }
   }

    @objc public func hide() {
        onChatClose {
            //nothing to do here
        }
    }
    
    func onChatClose(completion:@escaping(() -> Void)) {
        if self.verloopController != nil {
            self.verloopNavigationController?.dismiss(animated: true, completion: {
                completion()
            })
        } else {
            completion()
        }
    }
    
    //below are the 3 objects which will be prepare as part of the JSCallback delegate methods for button click, urlclick and client info
    private struct ClientInfo: Decodable {
        public let title: String
        public let bgColor: String
        public let textColor: String
    }
    
    private struct OnButtonClick: Decodable {
        public let title: String
        public let type: String
        public let payload: String
    }
    
    private struct OnURLClick: Decodable {
        public var url:String
    }
    
    //MARK: - Initiating API request to update the navigation bar's bgColor, text color, and title.
    private func getNavigationInfo() {
        let requestComponents: VLNetworkManagerRequestComponents = VLNetworkManagerRequestComponents(method: .get)
        VLNetworkManager.shared.request(url: config.getLiveChatInitUrl, requestComponents: requestComponents) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let responseData):
                guard let data = responseData else { return }
                do {
                    let response: VLClientInfoSchema? = try JSONDecoder().decode(VLClientInfoSchema.self, from: data)
                    self.config.updateClientInitInfo(response: response)
                    DispatchQueue.main.async {
                        self.refreshClientInfo()
                    }
                } catch let error {
                    print(error)
                    DispatchQueue.main.async {
                        self.refreshClientInfo()
                    }
                }
                
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.refreshClientInfo()
                }
            }
        }
    }
}
