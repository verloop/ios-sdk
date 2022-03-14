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
    
    private var previousWindow: UIWindow? = nil
    private var window = UIWindow()
    
    private var title = "Chat"
    private var bgColor: UIColor
    private var textColor: UIColor
    var reachability: Reachability?
    var bannerView:UIView?
    var lostNetworkConnection = false
    @objc public init(config vlConfig: VLConfig) {
        config = vlConfig
        config.save()
        
        bgColor = VerloopSDK.hexStringToUIColor(hex: "#000000")
        textColor = VerloopSDK.hexStringToUIColor(hex: "#ffffff")
        
        super.init()
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)
        if !config.getUpdatedConfigParams().isEmpty {
            print("params \(config.getUpdatedConfigParams())")
            forceWebViewToReloadConfiguration(configParam: config.getUpdatedConfigParams())
        }
        startHost(host: "google.com")
    }
    
    deinit {
        verloopNavigationController = nil
        verloopController = nil
        previousWindow = nil
        stopNotifier()
    }
    
    @objc public func closeWidget() {
            onChatClose()
        self.verloopNavigationController?.dismiss(animated: true, completion: {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {[weak self] in
                self?.manager.closeWidget()
            }
        })
    }
    
    @objc public func openWidget(rootController:UIViewController) {
    
//        start()
        verloopNavigationController = getNavController()
        print("widget opened")
        rootController.present(verloopNavigationController!, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {[weak self] in
                self?.manager.openWidget()
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
    
    private func forceWebViewToReloadConfiguration(configParam:[VLConfig.ConfigParam]) {
        manager.updateWebviewConfiguration(config,param: configParam)
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
        clearConfig()
        config.clearUserDetails()
        manager.clearLocalStorage()
        manager.logoutSession()
//        manager.setConfig(config: config)
    }
    
    @objc public func clearConfig(){
        config.clear()
        manager.clearConfig(config: config)
        self.config = VLConfig(clientId: "")
    }
    
    public func getConfig() -> VLConfig {
        return config
    }
    
    @objc public func getNavController() -> UINavigationController {
        
        if verloopNavigationController != nil {
            
            print("Already initialized")
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
    
        
        return verloopNavigationController!
    }
    
    func refreshClientInfo() {
        print("refreshClientInfo")
        verloopController?.title = title
        verloopNavigationController?.navigationBar.barTintColor = bgColor
        verloopNavigationController?.navigationBar.tintColor = textColor
        // TODO: In VLViewController, the leftBarButtonItem is set on controller's navigationItem and here it was being set on verloopNavigationController's navigationItem that was creating issue and leftBarItem's tint color was nil
        verloopController?.navigationItem.leftBarButtonItem?.tintColor = textColor
        verloopNavigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
//        manager.setConfig(config: config)
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
    
    func refreshwebViewOnNetworkReconnection() {
        manager.setConfig(config: config)
    }

    func jsCallback(message: Any) {
        if let bodyString = message as? String,let bodyData = bodyString.data(using: .utf8) {
            do {
                if let expectedModelData = try JSONSerialization.jsonObject(with: bodyData, options: .init(rawValue: 0)) as? [String:Any] {
                    if (expectedModelData["fn"] as? String ?? "") == "callback",
                       let arguments = expectedModelData["args"] as? [Any],let firstArg = arguments.first,((firstArg as? String) != nil)  {
                        if (firstArg as? String ?? "") == "button-clicked" {
                            print("bttn clock")
                            config.getButtonClickListener()?("Button", "callback", "NA")
                        } else if (firstArg as? String ?? "") == "url-clicked" {
                            print("url clock")
                            config.getButtonClickListener()?("URL", "callback", "NA")
                        }
                    } else if (expectedModelData["fn"] as? String ?? "") == "ready",
                              let arguments = expectedModelData["args"] as? [String:String],let colorArg = arguments["color"],!colorArg.isEmpty {
                        print("color \(colorArg)")
                        bgColor = VerloopSDK.hexStringToUIColor(hex: colorArg)
                        verloopController?.dismissLoader()
                        refreshClientInfo()
                    }
                }
            } catch {
                print("didReceiveMessage decode error \(error)")
            }
        }
    }
    
    @objc public func start() {
        previousWindow = UIApplication.shared.keyWindow
        window.isOpaque = true
        window.backgroundColor = UIColor.white
        window.frame = UIScreen.main.bounds//UIApplication.shared.keyWindow!.frame
        window.windowLevel = UIWindow.Level.normal + 1
        window.rootViewController = getNavController()
        window.makeKeyAndVisible()
    }
    
    
    @objc public func hide() {
        onChatClose()
    }
    
    func onChatClose() {
        if previousWindow != nil {
            window.resignKey()
            previousWindow!.makeKeyAndVisible()
            previousWindow = nil
            window.windowLevel = UIWindow.Level.normal - 30
        }
    }
    
    func onTransition() {
        NSLog("onTransiotion")
        
    }
    
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
        public let url: String
    }
}
