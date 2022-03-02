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
    
    @objc public init(config vlConfig: VLConfig) {
        config = vlConfig
        config.save()
        
        bgColor = VerloopSDK.hexStringToUIColor(hex: "#000000")
        textColor = VerloopSDK.hexStringToUIColor(hex: "#ffffff")
        
        super.init()
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)

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
        config.clearUserDetails()
        manager.clearLocalStorage()
        manager.setConfig(config: config)
    }
    
    @objc public func clearConfig(){
        config.clear()
        manager.clearConfig(config: config)
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
        print("Updating Client Info")
        refreshClientInfo()
        print("Updated Client Info")

        verloopNavigationController!.navigationItem.leftItemsSupplementBackButton = true
        
        verloopNavigationController!.navigationItem.hidesBackButton = false
        verloopNavigationController!.navigationItem.backBarButtonItem?.isEnabled = true
    
        
        return verloopNavigationController!
    }
    
    func refreshClientInfo() {
        verloopController?.title = title
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = bgColor
            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: textColor]
            verloopNavigationController?.navigationBar.standardAppearance = appearance;
            verloopNavigationController?.navigationBar.scrollEdgeAppearance = verloopNavigationController?.navigationBar.standardAppearance
            
        } else {
            verloopNavigationController?.navigationBar.barTintColor = bgColor
            verloopNavigationController?.navigationBar.tintColor = textColor

        }

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
    
    func jsCallback(message: Any) {
        let str = message as! String
        let data = str.data(using: String.Encoding.utf8)!
        print("button clicked 1")
        do {
           let clientInfo =  try JSONDecoder().decode(ClientInfo.self, from: data)
           title = clientInfo.title
           bgColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.bgColor)
           textColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.textColor)

           refreshClientInfo()
        }catch {
           print("Problem retreiving client Info")
        }
        do {
           let buttonInfo =  try JSONDecoder().decode(OnButtonClick.self, from: data)
           let title = buttonInfo.title
           let type = buttonInfo.type
           let payload = buttonInfo.payload

           if config.onButtonClicked != nil{
               config.onButtonClicked?(title, type, payload)
           }
        }catch {
           print("Problem retreiving button Info")
        }
        do {
           let urlInfo =  try JSONDecoder().decode(OnURLClick.self, from: data)
           let url = urlInfo.url

           if config.onUrlClicked != nil{
               config.onUrlClicked?(url)
           }
       }catch {
           print("Problem retreiving url Info")
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

