//
//  VLWebView.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 29/01/22
//

import UIKit
import WebKit

class VLWebView: WKWebView {
    private var  mWebViewConfigParams:VLConfiguration!
    var _eventDelegate:VLEventDelegate?
    
    func updateWebviewConfiguration(_ config:VLConfiguration) {
        self.mWebViewConfigParams = config
    }
}

extension VLWebView:WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        _eventDelegate?.didEventOccurOnLiveChat(.onChatMaximized)
    }
}

extension VLWebView:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        _eventDelegate?.didEventOccurOnLiveChat(.onIncomingMessage(VLMessage(message: message.body as? String)))
    }
}
