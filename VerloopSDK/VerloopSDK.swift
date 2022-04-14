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
    private var manager: VLWebViewManager!
    private var verloopController: VLViewController? = nil
    private var verloopNavigationController: UINavigationController? = nil

    
    private var title = ""
    private var bgColor: UIColor
    private var textColor: UIColor
    var reachability: Reachability?
    var lostNetworkConnection = false
    @objc public init(config vlConfig: VLConfig) {
        config = vlConfig
        //Storing config params in user defaults
        config.save()
        bgColor = .clear
        textColor = VerloopSDK.hexStringToUIColor(hex: "#ffffff")
        
        super.init()
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)
        //TODO property needed for manager.to be removed
        manager.onMessageReceived = {[weak self] in
            print("refreshClientInfo")
            self?.refreshClientInfo()
        }
        //Part of network reachability
        startHost(host: "verloop.io")
    }
    
    deinit {
        verloopNavigationController = nil
        verloopController = nil
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
    }
    @objc public func clearLocalStorage(){
        manager.clearCookies()

    }
    public func getConfig() -> VLConfig {
        return config
    }
    
    @objc public func getNavController() -> UINavigationController {

            

            if verloopNavigationController != nil {

                return verloopNavigationController!

            }

            

            verloopController = VLViewController.init()

            verloopController!.setWebView(webView: manager)

            verloopController!.title = title

            verloopController!.setSDK(verloopSDK: self)

            verloopNavigationController = VLNavViewController.init(rootViewController: verloopController!)

            verloopNavigationController!.navigationItem.leftItemsSupplementBackButton = true

            verloopNavigationController!.navigationItem.hidesBackButton = false

            verloopNavigationController!.navigationItem.backBarButtonItem?.isEnabled = true


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

        print("refreshClientInfo")

        verloopController?.title = title

        verloopNavigationController?.navigationBar.backgroundColor = bgColor

        verloopNavigationController?.navigationBar.barTintColor = bgColor

        verloopNavigationController?.navigationBar.isTranslucent = false

        // TODO: In VLViewController, the leftBarButtonItem is set on controller's navigationItem and here it was being set on verloopNavigationController's navigationItem that was creating issue and leftBarItem's tint color was nil

        verloopController?.navigationItem.leftBarButtonItem?.tintColor = textColor

        verloopNavigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]

    }

    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
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
        print("refreshwebViewOnNetworkReconnection")
        manager.executeNetworkChangeConfigurations()
    }

    //following is a delegate method of JsDelegate which is responsible for handling back call backs to the client app for
    //button clicks
    //url clicks
    //where as 'ready' call back is used to identify the color code of the navigation bar and title
    //below method executes when user made a selection on the webview for links / buttons
    func jsCallback(message: Any) {

            print("jsCallback")

        if message is String,let data = (message as? String)?.data(using: String.Encoding.utf8) {
            do {
                let clientInfo = try JSONDecoder().decode(ClientInfo.self, from: data)
                bgColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.bgColor)
                textColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.textColor)
                title = clientInfo.title
                verloopController?.dismissLoader()
                refreshClientInfo()
                manager.updateReadyState(true)
            } catch {
            }
            
            do {
                   let buttonInfo =  try JSONDecoder().decode(OnButtonClick.self, from: data)
                   let title = buttonInfo.title ?? ""
                   let type = buttonInfo.type ?? ""
                   let payload = buttonInfo.payload ?? ""
                if type.lowercased() == MessageType.MessageButtonClick.rawValue.lowercased() {
                    config.getButtonClickListener()?(title,type, payload)
                } else if type.lowercased() == MessageType.MessageURLClick.rawValue.lowercased() {
                    config.getURLClickListener()?(buttonInfo.payload)
                }
                    
                    
                  print("buttton click ")
                }catch {
                   print("Problem retreiving button Info \(error)")
                }
            
        }
        
    
        }
    

    
    @objc public func hide() {
        onChatClose {
            //nothing to do here
        }
    }
    
    func onChatClose(completion:@escaping(() -> Void)) {
        
        self.verloopNavigationController?.dismiss(animated: true, completion: {
            completion()
        })
    }
    
    //below are the 3 objects which will be prepare as part of the JSCallback delegate methods for button click, urlclick and client info
    private struct ClientInfo: Decodable {
        public let title: String
        public let bgColor: String
        public let textColor: String
    }
    
    private struct OnButtonClick: Decodable {
        public let title: String?
        public let type: String?
        public let payload: String?
    }
    
    private struct OnURLClick: Decodable {
        public var title:String?
        public var type:String?
        public var payload:String?
    }
}
