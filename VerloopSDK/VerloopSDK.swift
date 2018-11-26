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

open class VerloopSDK: VLJSInterface {
    private var config: VLConfig
    private var manager: VLWebViewManager
    private var verloopController: VLViewController? = nil
    private var verloopNavigationController: UINavigationController? = nil
    
    private var title = "Chat"
    private var bgColor: UIColor
    private var textColor: UIColor
    
    public init(controller uiController: UIViewController, config vlConfig: VLConfig) {
        config = vlConfig
        config.save()
        
        bgColor = VerloopSDK.hexStringToUIColor(hex: "#000000")
        textColor = VerloopSDK.hexStringToUIColor(hex: "#ffffff")
        
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)
    }
    
    public func getNavController() -> UINavigationController {
        if verloopNavigationController != nil {
            return verloopNavigationController!
        }
        
        verloopController = VLViewController.init()
        verloopController!.setWebView(webView: manager)
        verloopController!.title = title
        
        verloopNavigationController = UINavigationController.init(rootViewController: verloopController!)
        
        refreshClientInfo()
        
        verloopNavigationController!.navigationItem.leftItemsSupplementBackButton = true
        
        verloopNavigationController!.navigationItem.hidesBackButton = false
        verloopNavigationController!.navigationItem.backBarButtonItem?.isEnabled = true
        
        return verloopNavigationController!
    }
    
    private func refreshClientInfo() {
        verloopController?.title = title
        verloopNavigationController?.navigationBar.barTintColor = bgColor
        verloopNavigationController?.navigationBar.tintColor = textColor
        
        verloopNavigationController?.navigationItem.leftBarButtonItem?.tintColor = textColor
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
        guard let m =  try? JSONDecoder().decode(ClientInfo.self, from: data) else {
            NSLog("Problem retreiving client Info")
            return
        }
        
        title = m.title
        bgColor = VerloopSDK.hexStringToUIColor(hex: m.bgColor)
        textColor = VerloopSDK.hexStringToUIColor(hex: m.textColor)
        
        refreshClientInfo()
    }
    
    private struct ClientInfo: Decodable {
        public let title: String
        public let bgColor: String
        public let textColor: String
    }
}
