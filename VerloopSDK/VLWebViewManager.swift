//
//  VerloopWebViewManager.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 24/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import Foundation
import WebKit

enum VLError:Error {
    case InvalidSourceName
    case JSONParseError
}

class VLWebViewManager: NSObject,WKUIDelegate, WKNavigationDelegate {
    var webView: WKWebView!
    private var hasTriedToStartRoom = false
    private var jsInterface: VLJSInterface? = nil
    private var isRoomReady = false
    private var isReady = false
    private var isReadyForPassConfigs = false
    private var config: VLConfig!
    private var roomReadyConfigurations:[VLConfig.APIMethods] = []
    private var networkChangesConfigurations:[VLConfig.APIMethods] = []
    private lazy var contentController: WKUserContentController = {
        return webView.configuration.userContentController
    }()
    var _eventDelegate:VLEventDelegate?
    private var configParams:[VLConfig.APIMethods] = []
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
        isReadyForPassConfigs = false
//        self.loadWebView()
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
    
    func launchWebView() {
        print("launchWebView")
        self.loadWebView()
    }
    
    func setConfig(config: VLConfig){
        self.config = config
        if isReadyForPassConfigs {
            self.processConfigurations()
        }
        //no need to reload entire webview, just pass the modified config params
//        self.loadWebView()
    }

    func clearLocalStorageVistorToken(){
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
    
    func logoutSession() {
        webView.evaluateJavaScript(String.getLogoutEvaluationJS()) {[weak self] _, error in
            print("logout error \(error?.localizedDescription ?? "NA")")
            if error == nil {// when user is logged out, clear the local cookies
                self?.clearLocalStorageVistorToken()
            }
        }
    }
    
    func closeWidget(hasInternet:Bool) {
        print("closeWidget \(isReady)")
        if !isReady,hasInternet {
            if !networkChangesConfigurations.contains(.closeWidget) {
                networkChangesConfigurations.append(.closeWidget)
            }
        } else if isReady {
            webView.evaluateJavaScript(String.getWidgetClosedEvaluationJS()) {[weak self] _, error in
                print("closeWidget error \(error?.localizedDescription ?? "NA")")
                if error == nil {
//                    self?._eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
//                    self?._eventDelegate?.didReceiveEventChatMinimized?(<#T##message: Any##Any#>)
                    self?._eventDelegate?.onChatMinimized?()
                }
            }
        }
    }
    
    func openWidget() {
        print("openWidget")
        webView.evaluateJavaScript(String.getWidgetOpenedEvaluationJS()) {[weak self] _, error in
            print("openWidget error \(error?.localizedDescription ?? "NA")")
            if error == nil {
                self?._eventDelegate?.onChatMaximized?()
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

//           //you might want to edit the script, with the escape characters
//           let script = "localStorage.getItem(\"visitorToken\")"
//           webView.evaluateJavaScript(script) { (token, error) in
//               if let error = error {
//                   print ("localStorage.getitem('visitorToken') failed due to \(error)")
//               }
//               print("token = \(String(describing: token))")
//           }
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
//                            self?._eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
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
                        webView.evaluateJavaScript(String.getUserIdEvaluationJS(unwrapped)) { _, error in
                            print("set user id error \(error?.localizedDescription ?? "NIL")")
                        }
                    }
                case .recipe:
                    if let unwrapped = config.getRecipeId(),!unwrapped.isEmpty {
                        print("unwrapped recipe \(unwrapped)")
                        webView.evaluateJavaScript(String.getRecipeEvaluationJS(unwrapped)) { _, error in
                            print("set recipe error \(error?.localizedDescription ?? "NIL")")
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
                        print("unwrapped recipe \(unwrapped)")
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
//        print("message.name and message.body are \(message.name) \(message.body)")

        if (message.name == Constants.SCRIPT_MESSAGE_NAME) {
                if jsInterface != nil {
                    jsInterface?.jsCallback(message: message.body)
                }
        } else if (message.name == Constants.SCRIPT_MESSAGE_NAME_V2){
            do {
                try handleWebPostMessage(message.body)
            } catch {
                print("handleWebPostMessage error \(error)")
            }
        } else{
            print("unrecognized callback")
        }
    }
    
    func handleWebPostMessage(_ msg:Any) throws {
        if let bodyString = msg as? String,let bodyData = bodyString.data(using: .utf8) {
            var modelObject:ExpectedEventPayload?
            do {
                let expectedModelData = try JSONSerialization.jsonObject(with: bodyData, options: .init(rawValue: 0))
                let expectedData = try JSONSerialization.data(withJSONObject: expectedModelData, options: .prettyPrinted)
                modelObject = try JSONDecoder().decode(ExpectedEventPayload.self, from: expectedData)
            } catch {
                print(" handleWebPostMessage json parse error \(error)")
                throw VLError.JSONParseError
            }
//                print("model \(model)")
            guard let model = modelObject,let src = model.src,src.lowercased() == Constants.JS_MESSAGE_NAME.lowercased() else {
                print("source is not a verloop")
                throw VLError.InvalidSourceName
            }
            print("model.fn \(model.fn)")
            if let  _function = model.fn {
                print("call back function \(_function)")
                switch _function {
                case .FunctionSetUserIdComplete:
                    break
                case .FunctionSetUserParamComplete:
                    break
                case .FunctionCloseWidget:
                    clearLocalStorageVistorToken()
                    self.didReceiveCallbackEventsOnLivechat(message: bodyString,data: bodyData)
                case .FunctionOnRoomReady:
                    print("FunctionOnRoomReady")
                    isRoomReady = true
                    processRoomReadyConfigurations()
                case .FunctionCallBack:
                    self.didReceiveCallbackEventsOnLivechat(message: bodyString,data: bodyData)
                case .FunctionReady:
                    print("FunctionReady")
                    isReadyForPassConfigs = true
                    processConfigurations()
                    webView.evaluateJavaScript("VerloopLivechat.widgetOpened()")
                    _eventDelegate?.onWidgetLoaded?()
                case .FunctionCloseComplete:
                    clearLocalStorageVistorToken()
                    self.didReceiveCallbackEventsOnLivechat(message: bodyString, data: bodyData)
                case .FunctionChatMinimized:
                    _eventDelegate?.onChatMinimized?()
                    //                            _eventDelegate?.didEventOccurOnLiveChat(.onChatMinimized)
                case .FunctionChatMaximized:
                    _eventDelegate?.onChatMaximized?()
                    //                            _eventDelegate?.didEventOccurOnLiveChat(.onChatMaximized)
                case .FunctionChatEnded:
                    _eventDelegate?.onChatEnded?()
                    //                            _eventDelegate?.didEventOccurOnLiveChat(.onChatEnded)
                case .FunctionChatStarted:
                    //                            onMessageReceived?()
                    _eventDelegate?.onChatStarted?()
                    //                            _eventDelegate?.didEventOccurOnLiveChat(.onChatStarted)
                case .FunctionChatMessageReceived:
                    _eventDelegate?.onIncomingMessage?(bodyString)
                default:break
                }
            }
        }
    }
    
    private func didReceiveCallbackEventsOnLivechat(message:String,data:Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any] {
                    var firstArg = ""
                    if let args = json["args"] as? [Any],let first = args.first as? String {
                        firstArg = first
                    } else if let args = json["args"] as? String {
                        firstArg = args
                    }
                    print("firstArg \(firstArg)")
                    switch firstArg {
                        case FunctionType.FunctionChatMessageReceived.rawValue:
                        if let args = json["args"] as? [Any] {
                            for arg in args {
                                if arg is [String:Any],(arg as! [String:Any]).keys.first ?? "" == "message",
                                   let messagedict = (arg as! [String:Any])["message"] as? [String:Any],
                                   let message = messagedict["msg"] as? String {
                                    print("chat message \(message)")
                                    _eventDelegate?.onIncomingMessage?(message)
                                    break
                                }
                            }
                        }
                        case FunctionType.FunctionChatEnded.rawValue:
                            _eventDelegate?.onChatEnded?()
                        case FunctionType.FunctionChatStarted.rawValue:
                            _eventDelegate?.onChatStarted?()
                        case FunctionType.FunctionLogOutCompleted.rawValue:
                            _eventDelegate?.onLogoutComplete?()
                        default:break
                    }
            }
        } catch {
            print("didReceiveCallbackEventsOnLivechat parse error \(error)")
        }
    }
}

extension VLWebViewManager:VLViewControllerLifeCycleDelegate {
    func VLViewControllerViewdidLoad() {
        //nothing to do for now
    }
    
    func VLViewControllerViewWillAppear() {
        print("VLViewControllerViewWillAppear")
        launchWebView()
    }
    
    func VLViewControllerViewDidAppear() {
        //nothing to do for now
    }
    
    func VLViewControllerViewWillDisappear() {
        
        isReadyForPassConfigs = false
        isReady = false
    }
    
    func VLViewControllerViewdidDisappeaar() {
//        webView.stopLoading()
    }
}
