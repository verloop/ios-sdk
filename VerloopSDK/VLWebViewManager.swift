//
//  VerloopWebViewManager.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 24/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import Foundation
import WebKit

class VLWebViewManager: NSObject,WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    private var hasTriedToStartRoom = false
    private var jsInterface: VLJSInterface? = nil
    private var config: VLConfig!
    private lazy var contentController: WKUserContentController = {
        return webView.configuration.userContentController
    }()
    var _eventDelegate:VLEventDelegate?
    private var configParams:[VLConfig.ConfigParam] = []
    
    init(config: VLConfig) {
        
        self.config = config

        super.init()
        
        webView =  WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        subscribeMessageHandler()
//        webView.configuration.userContentController.add(self, name: "VerloopMobile")
        webView.isOpaque = true

        self.loadWebView()
    }
    
    deinit {
        unsubscribeMessageHandler()
    }
    
    private func subscribeMessageHandler() {
        let handler = ScriptMessageHandler()
        handler.delegate = self
        contentController.add(handler, name: Constants.SCRIPT_MESSAGE_NAME_V2)
    }
    
    private func unsubscribeMessageHandler() {
        contentController.removeScriptMessageHandler(forName: Constants.SCRIPT_MESSAGE_NAME_V2)
    }
    
    func setConfig(config: VLConfig){
        
        self.config = config
        self.loadWebView()
    }
    
    func updateWebviewConfiguration(_ config:VLConfig,param:[VLConfig.ConfigParam]) {
        print("updateWebviewConfiguration")
        self.config = config
        configParams = param
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
        urlComponents.scheme = Constants.URL_SCHEME;
        
        if self.config.isStagingEnvironment() {
            urlComponents.host =  self.config.getClientID() + Constants.URL_STAGING;
        } else {
            urlComponents.host =  self.config.getClientID() + Constants.URL_PROD;
        }
        
        urlComponents.path = "/livechat";
        
        urlComponents.queryItems = [
            URLQueryItem(name: "mode", value: Constants.URL_QUERY_MODE),
            URLQueryItem(name: "sdk", value: Constants.URL_QUERY_SDK),
        ]
        
//        if self.config.getUserID() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "user_id", value: self.config.getUserID()!))
//        }
//
//        if self.config.getNotificationToken() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "device_token", value: self.config.getNotificationToken()!))
//            urlComponents.queryItems?.append(URLQueryItem(name: "device_type", value: "ios"))
//        }
//
//        if self.config.getCustomFieldsJSON() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "custom_fields", value: self.config.getCustomFieldsJSON()!))
//        }
//
//        if self.config.getUsername() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "name", value: self.config.getUsername()!))
//        }
//
//        if self.config.getUserEmail() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "email", value: self.config.getUserEmail()!))
//        }
//
//        if self.config.getUserPhone() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "phone", value: config.getUserPhone()!))
//        }
//
//        if self.config.getRecepieId() != nil {
//            urlComponents.queryItems?.append(URLQueryItem(name: "recipe_id", value: self.config.getRecepieId()!))
//        }
        
        print("Starting chat. " + urlComponents.string!)
        
        let url = URL(string: urlComponents.string!)
        let request = URLRequest(url: url!)
        
        webView.load(request)
    }
        
    func jsDelegate(delegate: VLJSInterface) {
        jsInterface = delegate
    }
    
    func addEventChangeDelegate(_ delegate:VLEventDelegate?) {
        _eventDelegate = delegate
    }
    
    func startRoom() {
        hasTriedToStartRoom = true
        webView.evaluateJavaScript("VerloopLivechat.start();")
    }
    
    func logoutSession() {
        webView.evaluateJavaScript(String.getLogoutEvaluationJS()) { _, error in
            print("logout error \(error)")
        }
    }
    
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if (message.name == "VerloopMobile") {
//            if jsInterface != nil {
//                jsInterface?.jsCallback(message: message.body)
//            }
//        }
//
//        if (hasTriedToStartRoom) {
//            startRoom()
//        }
//    }
    
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
//        let script = "localStorage.getItem(\"visitorToken\")"
//        webView.evaluateJavaScript(script) { (token, error) in
//            if let error = error {
//                print ("localStorage.getitem('visitorToken') failed due to \(error)")
//                assertionFailure()
//            }
//            print("token = \(String(describing: token))")
//        }
        cleaerCookies()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            if self.config.isURLRedirection() {
                decisionHandler(.allow)
            }
            else {
                decisionHandler(.cancel)
            }
        }
        else {
            decisionHandler(.allow)
        }
    }
}

extension VLWebViewManager {
    
    private func cleaerCookies() {
        let script = "localStorage.getItem(\"visitorToken\")"
        webView.evaluateJavaScript(script) { (token, error) in
            if let error = error {
                print ("localStorage.getitem('visitorToken') failed due to \(error)")
                assertionFailure()
            }
            print("token = \(String(describing: token))")
        }
    }
    
    private func processConfigurations() {
        print("processConfigurations \(configParams)")
        for parameter in configParams {
            print("parameter \(parameter)")
            switch parameter {
                case .userParams:
                if !config.getUserParams().isEmpty {
                    for userParam in config.getUserParams() {
                        print("userParam \(userParam)")
                        webView.evaluateJavaScript(String.getUserParamEvaluationJS(key: userParam.key, value: userParam.value)) { _, error in
                                print("set custom field error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                }
                case .userId:
                    if let unwrapped = config.getUserID() {
                        webView.evaluateJavaScript(String.getUserIdEvaluationJS(unwrapped, optionArgument: nil)) { _, error in
                            print("set user id error \(error?.localizedDescription ?? "NIL")")
                        }
                        webView.evaluateJavaScript(String.getUserParamEvaluationJS(key: "name", value: "sreedeep")) { _, error in
                                print("set user param field error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                case .recepie:
                    if let unwrapped = config.getRecepieId(),!unwrapped.isEmpty {
                        print("unwrapped recepie \(unwrapped)")
                        webView.evaluateJavaScript(String.getRecepieEvaluationJS(unwrapped)) { _, error in
                            print("set recepie error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                case .customFields:
                    if !config.getCustomFields().isEmpty {
                        for field in config.getCustomFields() {
                            webView.evaluateJavaScript(String.getCustomFieldEvaluationJS(field)) { _, error in
                                print("set custom field error \(error?.localizedDescription ?? "NIL")")
                            }
                        }
                    }
                case .department:
                    if let unwrapped = config.getDepartment(),!unwrapped.isEmpty {
                        print("unwrapped recepie \(unwrapped)")
                        webView.evaluateJavaScript(String.getDepartmentEvaluationJS(dept: unwrapped)) { _, error in
                            print("set department error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                case .clearDepartment:
                    webView.evaluateJavaScript(String.getClearDepartmentEvaluationJS()) { _, error in
                        print("set clear department error \(error?.localizedDescription ?? "NIL")")

                    }
                default : break
            }
        }
    }
}

extension VLWebViewManager:ScriptMessageDelegate {
    func handler(_ scriptMessageHandler: ScriptMessageHandler, didReceiveMessage message: WKScriptMessage) {
            if (message.name == Constants.JS_MESSAGE_NAME) {
                if jsInterface != nil {
                    jsInterface?.jsCallback(message: message.body)
                }
            }
            if (hasTriedToStartRoom) {
                startRoom()
            }
        handleWebPostMessage(message.body)
    }
    
    private func handleWebPostMessage(_ msg:Any) {
        if let bodyString = msg as? String,let bodyData = bodyString.data(using: .utf8) {
            do {
                let expectedModelData = try JSONSerialization.jsonObject(with: bodyData, options: .init(rawValue: 0))
//                print("expectedModelData \(expectedModelData)")
                let expectedData = try JSONSerialization.data(withJSONObject: expectedModelData, options: .prettyPrinted)
                let model = try JSONDecoder().decode(ExpectedEventPayload.self, from: expectedData)
                if let _modelType = model.type {
                    switch _modelType {
                        //button click and URL click
                        case .MessageButtonClick:
//                            break
                            _eventDelegate?.didEventOccurOnLiveChat(.onButtonClick)
                        case .MessageURLClick:
//                            break
                            _eventDelegate?.didEventOccurOnLiveChat(.onURLClick)
                    }
                } else if let  _function = model.fn {
                    switch _function {
                        case .FunctionSetUserIdComplete:
                            _eventDelegate?.didEventOccurOnLiveChat(.setUserIdComplete)
                        case .FunctionSetUserParamComplete:
                            _eventDelegate?.didEventOccurOnLiveChat(.setUserParamComplete)
                        case .FunctionCloseWidget:
                            cleaerCookies()
                            _eventDelegate?.didEventOccurOnLiveChat(.onWidgetClosed)
                        case .FunctionOnRoomReady:
                            print("FunctionOnRoomReady")
                        case .FunctionCallBack:
                            break
                        case .FunctionReady:
                            print("FunctionReady")
                            processConfigurations()
                        case .FunctionCloseComplete:
                            cleaerCookies()
                            _eventDelegate?.didEventOccurOnLiveChat(.onLogoutComplete)
                    }
                }
            } catch {
                print("didReceiveMessage decode error \(error)")
            }
        }
    }
}
