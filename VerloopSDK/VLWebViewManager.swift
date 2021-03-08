//
//  VerloopWebViewManager.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 24/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import Foundation
import WebKit

class VLWebViewManager: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    private var hasTriedToStartRoom = false
    private var jsInterface: VLJSInterface? = nil
    private var config: VLConfig!
    
    init(config: VLConfig) {
        
        self.config = config

        super.init()
        
        webView =  WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "VerloopMobile")
        webView.isOpaque = true

        self.loadWebView()
    }
    
    func setConfig(config: VLConfig){
        
        self.config = config
        self.loadWebView()
    }
    
    func clearLocalStorage(){
        let script = "localStorage.removeItem(\"visitorToken\")"
        webView.evaluateJavaScript(script) { (token, error) in
            if let error = error {
                print ("localStorage.removingitem('visitorToken') failed due to \(error)")
                assertionFailure()
            }
        }
    }
    
    
    func clearConfig(config: VLConfig){
        self.config = config
        let url = URL(string: "about:blank")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    private func loadWebView(){
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https";
        
        if self.config.isStaging {
            urlComponents.host =  self.config.clientId + ".stage.verloop.io";
        } else {
            urlComponents.host =  self.config.clientId + ".verloop.io";
        }
        
        urlComponents.path = "/livechat";
        
        urlComponents.queryItems = [
            URLQueryItem(name: "mode", value: "sdk"),
            URLQueryItem(name: "sdk", value: "ios"),
        ]
        
        if self.config.userId != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "user_id", value: self.config.userId!))
        }
        
        if self.config.notificationToken != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "device_token", value: self.config.notificationToken!))
            urlComponents.queryItems?.append(URLQueryItem(name: "device_type", value: "ios"))
        }
        
        if self.config.getCustomFieldsJSON() != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "custom_fields", value: self.config.getCustomFieldsJSON()!))
        }
        
        if self.config.userName != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "name", value: self.config.userName!))
        }
        
        if self.config.userEmail != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "email", value: self.config.userEmail!))
        }
        
        if self.config.userPhone != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "phone", value: config.userPhone!))
        }
        
        if self.config.recipeId != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "recipe_id", value: self.config.recipeId!))
        }
        
        print("Starting chat. " + urlComponents.string!)
        
        let url = URL(string: urlComponents.string!)
        let request = URLRequest(url: url!)
        
        webView.load(request)
    }
        
    func jsDelegate(delegate: VLJSInterface) {
        jsInterface = delegate
    }
    
    func startRoom() {
        hasTriedToStartRoom = true
        webView.evaluateJavaScript("VerloopLivechat.start();")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "VerloopMobile") {
            if jsInterface != nil {
                jsInterface?.jsCallback(message: message.body)
            }
        }
        
        if (hasTriedToStartRoom) {
            startRoom()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //you might want to edit the script, with the escape characters
        let script = "localStorage.getItem(\"visitorToken\")"
        webView.evaluateJavaScript(script) { (token, error) in
            if let error = error {
                print ("localStorage.getitem('visitorToken') failed due to \(error)")
                assertionFailure()
            }
            print("token = \(token)")
        }
    }
}
