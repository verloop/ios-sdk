//
//  VLChatViewController.swift
//  Verloop
//
//  Created by Sreedeep, Paul on 29/01/22.
//

import UIKit

class VLChatViewController: UIViewController {

    @IBOutlet weak var mWebView: VLWebView!
    private var mConfiguration:VLConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mConfiguration?.didUpdateConfiguration = {[weak self] config in
            self?.mConfiguration = config
            self?.forceWebViewToReloadConfiguration()
        }
        
        mConfiguration?.didRequestForNewEvent = {[weak self] event in
            self?.performRequestedEvent(event)
        }
    }
    
    convenience init(configuration config:VLConfiguration,callBackListener:VLEventDelegate?) {
        self.init()
        mConfiguration = config
        mWebView._eventDelegate = callBackListener
    }
    
    private func forceWebViewToReloadConfiguration() {
        guard let unwrapped = mConfiguration else {
            return
        }
        mWebView.updateWebviewConfiguration(unwrapped)
    }
    
    private func performRequestedEvent(_ event:VLConfiguration.VLConfigEvent) {
        switch event {
            case .vlOpenWidget:
                print("vlOpenWidget")
            case .vlCloseWidget:
                print("vlCloseWidget")
            case .vlLogout:
                print("vlLogout")
            case .vlWidgetColor(let color):
                print("vlWidgetColor \(color)")
        }
    }
}
