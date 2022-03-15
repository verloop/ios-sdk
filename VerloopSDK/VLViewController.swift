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
    private var loader : UIActivityIndicatorView?

    func setWebView(webView v: VLWebViewManager) {
        webView = v
        view.addSubview(webView!.webView)
        webView!.webView.frame = self.view.bounds
        loader = UIActivityIndicatorView(frame: CGRect(x: view.center.x, y: view.center.y, width: 30, height: 30))
        loader?.tintColor = .black
        if #available(iOS 13.0, *) {
            loader?.style = .large
        }
        loader?.center = self.view.center
        loader?.startAnimating()
        view.addSubview(loader!)
//        view.bringSubviewToFront(loader!)
        if isViewLoaded {
            webView!.startRoom()
        }
        
    }

    func setSDK(verloopSDK sdk: VerloopSDK) {
        verloopSDK = sdk
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if webView != nil {
            webView!.startRoom()
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "×", style: .done, target: self, action: #selector(back(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: The navigationBar's display (UI Color and frame), according to the client, needs to be changed everytime user comes back to the ChatBot window.
        if let sdk = verloopSDK,let status = sdk.reachability?.connection,status == .unavailable {
            let noNetworkAlert = UIAlertController(title: "Network", message: "No network connection available. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                
            }
            noNetworkAlert.addAction(okAction)
            self.present(noNetworkAlert, animated: true, completion: nil)
            loader?.removeFromSuperview()
        }
        webView?.webView.frame = self.view.bounds
    }

    func dismissLoader() {
        loader?.removeFromSuperview()
    }
    
    @objc func back(_ sender : AnyObject?) {
        if verloopSDK != nil {
            verloopSDK!.closeWidget()
        }
        self.dismiss(animated: true, completion: nil)
    }
}
