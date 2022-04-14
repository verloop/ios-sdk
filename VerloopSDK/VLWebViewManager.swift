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
    private var isRoomReady = false
    private var isReady = false
    private var config: VLConfig!
    private var roomReadyConfigurations:[VLConfig.ConfigParam] = []
    private var networkChangesConfigurations:[VLConfig.ConfigParam] = []
    private lazy var contentController: WKUserContentController = {
        return webView.configuration.userContentController
    }()
    var _eventDelegate:VLEventDelegate?
    private var configParams:[VLConfig.ConfigParam] = []
    var onMessageReceived:(() -> Void)?
    
    init(config: VLConfig) {
        
        self.config = config

        super.init()
        
        webView =  WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        subscribeMessageHandler()
//        webView.configuration.userContentController.add(self, name: "VerloopMobile")
        webView.isOpaque = true
        isRoomReady = false
        self.loadWebView()
    }
    
    deinit {
        unsubscribeMessageHandler()
    }
    
    func updateReadyState(_ isReady:Bool) {
        self.isReady = isReady
    }
    
    private func subscribeMessageHandler() {
        let handler = ScriptMessageHandler()
        handler.delegate = self
        contentController.add(handler, name: Constants.SCRIPT_MESSAGE_NAME_V2)
        contentController.add(handler, name: Constants.SCRIPT_MESSAGE_NAME)
    }
    
    private func unsubscribeMessageHandler() {
        contentController.removeScriptMessageHandler(forName: Constants.SCRIPT_MESSAGE_NAME_V2)
        contentController.removeScriptMessageHandler(forName: Constants.SCRIPT_MESSAGE_NAME)
    }
    
    func setConfig(config: VLConfig){
        self.config = config
        self.loadWebView()
    }
    
    func updateWebviewConfiguration(_ config:VLConfig,param:[VLConfig.ConfigParam]) {
        print("updateWebviewConfiguration")
    func clearCookies(){
        let script = "localStorage.removeItem(\"visitorToken\")"
        webView.evaluateJavaScript(script) { (token, error) in
            print("remove visitor token on logout")
            if let error = error {
                print ("localStorage removingitem visitorToken failed \(error)")
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
            URLQueryItem(name: "sdk", value: Constants.URL_QUERY_SDK),
        ]

        if self.config.getNotificationToken() != nil {
            urlComponents.queryItems?.append(URLQueryItem(name: "device_token", value: self.config.getNotificationToken()!))
            urlComponents.queryItems?.append(URLQueryItem(name: "device_type", value: "ios"))
        }
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
        webView.evaluateJavaScript(String.getLogoutEvaluationJS()) {[weak self] _, error in
            print("logout error \(error?.localizedDescription ?? "NA")")
            if error == nil {// when user is logged out, clear the local cookies
                self?.clearCookies()
            }
        }
    }
    
    func closeWidget(hasInternet:Bool) {
        if !isReady,hasInternet {
            if !networkChangesConfigurations.contains(.closeWidget) {
                networkChangesConfigurations.append(.closeWidget)
            }
        } else if isReady {
            webView.evaluateJavaScript(String.getWidgetClosedEvaluationJS()) {[weak self] _, error in
                print("closeWidget error \(error?.localizedDescription ?? "NA")")
                if error == nil {
                    self?._eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
                }
            }
        }
    }
    
    func openWidget() {
        webView.evaluateJavaScript(String.getWidgetOpenedEvaluationJS()) {[weak self] _, error in
            print("openWidget error \(error?.localizedDescription ?? "NA")")
            if error == nil {
                self?._eventDelegate?.didEventOccurOnLiveChat(.onChatMaximized)
            }
        }
    }
    
    func close() {
        if !isRoomReady {
            if !roomReadyConfigurations.contains(.close) {
                roomReadyConfigurations.append(.close)
            }
        } else {
            webView.evaluateJavaScript(String.getCloseEvaluateJS()) { _, error in
                print("close error \(error?.localizedDescription ?? "NA")")
            }
        }
    }
    
    func executeNetworkChangeConfigurations() {
        print("executeNetworkChangeConfigurations \(networkChangesConfigurations)")
        if !networkChangesConfigurations.isEmpty {
            processNetworkChangeConfigurations()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("createWebViewWith \(navigationAction)")
        guard let url = navigationAction.request.url else {
            return nil
        }
        
        if self.config.isURLRedirection() {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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
            print("##### Visistor token = \(String(describing: token))")
        }
//        clearCookies()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction \(navigationAction.request.url)")
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
    
    private func processRoomReadyConfigurations() {
        for config in roomReadyConfigurations {
            switch config {
                case .close :
                    webView.evaluateJavaScript(String.getCloseEvaluateJS()) { _, error in
                        print("getCloseEvaluateJS error \(error?.localizedDescription ?? "NA")")
                    }
                case .closeWidget:
                    webView.evaluateJavaScript(String.getWidgetClosedEvaluationJS()) {[weak self] _, error in
                        print("closeWidget error \(error?.localizedDescription ?? "NA")")
                        if error == nil {
                            self?._eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
                        }
                    }
                default: break
            }
        }
        roomReadyConfigurations = []
    }
    
    private func processNetworkChangeConfigurations() {
        print("networkChangesConfigurations")
        for config in networkChangesConfigurations {
            switch config {
                case .close :
                    webView.evaluateJavaScript(String.getCloseEvaluateJS()) { _, error in
                        print("getCloseEvaluateJS error \(error?.localizedDescription ?? "NA")")
                    }
                case .closeWidget:
                    webView.evaluateJavaScript(String.getCloseEvaluateJS()) { _, error in
                        print("closeWidget error \(error?.localizedDescription ?? "NA")")
                    }
                default: break
            }
        }
        networkChangesConfigurations = []
    }
    

    func processConfigurations() {
        print("processConfigurations \(self.config.getUpdatedConfigParams())")
        for parameter in self.config.getUpdatedConfigParams() {
            print("parameter \(parameter)")
            switch parameter {
                case .userParams:
                if !config.getUserParams().isEmpty {
                    for userParam in config.getUserParams() {
                        print("userParam \(userParam)")
                        webView.evaluateJavaScript(String.getUserParamEvaluationJS(key: userParam.key, value: userParam.value)) { _, error in
                                print("set user param error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                }
                case .userId:
                    if let unwrapped = config.getUserID() {
                        webView.evaluateJavaScript(String.getUserIdEvaluationJS(unwrapped, optionArgument: nil)) { _, error in
                            print("set user id error \(error?.localizedDescription ?? "NIL")")
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
        print("message.name and message.body are \(message.name) \(message.body)")
        //TODO handle v2 and non  v2 change
        if (message.name == Constants.SCRIPT_MESSAGE_NAME) {
                if jsInterface != nil {
                    jsInterface?.jsCallback(message: message.body)
                }
              
            }
        else if (message.name == Constants.SCRIPT_MESSAGE_NAME_V2){
            handleWebPostMessage(message.body)
        }
        else{
            print("unrecognized callback")
        }
    }
    
    private func handleWebPostMessage(_ msg:Any) {
        if let bodyString = msg as? String,let bodyData = bodyString.data(using: .utf8) {
            do {
                let expectedModelData = try JSONSerialization.jsonObject(with: bodyData, options: .init(rawValue: 0))
                let expectedData = try JSONSerialization.data(withJSONObject: expectedModelData, options: .prettyPrinted)
                let model = try JSONDecoder().decode(ExpectedEventPayload.self, from: expectedData)
                //TODO remove the _modelType part
                if let _modelType = model.type {
                    switch _modelType {
                        //button click and URL click
                        case .MessageButtonClick:
                            _eventDelegate?.didEventOccurOnLiveChat(.onButtonClick)
                        case .MessageURLClick:
                            _eventDelegate?.didEventOccurOnLiveChat(.onURLClick)
                    }
                } else if let  _function = model.fn {
                    switch _function {
                        case .FunctionSetUserIdComplete:
                            _eventDelegate?.didEventOccurOnLiveChat(.setUserIdComplete)
                        case .FunctionSetUserParamComplete:
                            _eventDelegate?.didEventOccurOnLiveChat(.setUserParamComplete)
                        case .FunctionCloseWidget:
                            clearCookies()
                            _eventDelegate?.didEventOccurOnLiveChat(.onWidgetClosed)
                        case .FunctionOnRoomReady:
                            print("FunctionOnRoomReady")
                            isRoomReady = true
                            processRoomReadyConfigurations()
                        case .FunctionCallBack:
                            break
                        case .FunctionReady:
                            print("FunctionReady")
                            processConfigurations()
                            webView.evaluateJavaScript("VerloopLivechat.widgetOpened()")
                        case .FunctionCloseComplete:
                            clearCookies()
                            _eventDelegate?.didEventOccurOnLiveChat(.onLogoutComplete)
                        case .FunctionChatMinimized:
                            _eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
                        case .FunctionChatMaximized:
                            _eventDelegate?.didEventOccurOnLiveChat(.onChatMaximized)
                        case .FunctionChatEnded:
                            _eventDelegate?.didEventOccurOnLiveChat(.onChatEnded)
                        case .FunctionChatStarted:
//                            onMessageReceived?()
                            _eventDelegate?.didEventOccurOnLiveChat(.onChatStarted)
                    }
                }
            } catch {
                print("didReceiveMessage decode error \(error)")
            }
        }
    }
}
