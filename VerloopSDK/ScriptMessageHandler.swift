//
//  ScriptMessageHandler.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 05/02/22.
//

import WebKit

protocol ScriptMessageDelegate: AnyObject {
    func handler(_ scriptMessageHandler: ScriptMessageHandler, didReceiveMessage message: WKScriptMessage)
}

class ScriptMessageHandler: NSObject {
    weak var delegate: ScriptMessageDelegate?
}

extension ScriptMessageHandler:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("original ScriptMessageHandler userContentController \(message.body)")
//        guard let body = message.body as? [String: Any] else { return }
        delegate?.handler(self, didReceiveMessage: message)
    }
}
