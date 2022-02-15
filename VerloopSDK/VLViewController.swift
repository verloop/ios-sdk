//
//  VLController.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import UIKit
import WebKit

class VLViewController: UIViewController, WKUIDelegate {
    private var verloopSDK: VerloopSDK? = nil

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    init(webView: VLWebViewManager) {
        super.init(nibName: nil, bundle: nil)
        setWebView(webView: webView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var webView: VLWebViewManager?
    //var loader : UIView!   // Check

    func setWebView(webView v: VLWebViewManager) {
        webView = v
        view.addSubview(webView!.webView)
        webView!.webView.frame = view.bounds

        if isViewLoaded {
            webView!.startRoom()
        }
        
    }

    func setSDK(verloopSDK sdk: VerloopSDK) {
        verloopSDK = sdk
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//
//
//        loaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 100, height: 100))
//        loaderView.backgroundColor = UIColor.black
//        view.addSubview(loaderView)
//        loaderView.bringSubviewToFront(view)
        


        if webView != nil {
            webView!.startRoom()
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "×", style: .done, target: self, action: #selector(back(_:)))

    }

    override func viewWillAppear(_ animated: Bool) {
                
        super.viewWillAppear(animated)
        // TODO: The navigationBar's display (UI Color and frame), according to the client, needs to be changed everytime user comes back to the ChatBot window.
        verloopSDK?.refreshClientInfo()
        webView?.webView.frame = view.bounds
        
    }

    @objc func back(_ sender : AnyObject?) {
        if verloopSDK != nil {
            verloopSDK!.onChatClose()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
