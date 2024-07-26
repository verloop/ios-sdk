//
//  VLController.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import UIKit
import WebKit


protocol VLViewControllerLifeCycleDelegate {
    func VLViewControllerViewdidLoad()
    func VLViewControllerViewWillAppear()
    func VLViewControllerViewDidAppear()
    func VLViewControllerViewWillDisappear()
    func VLViewControllerViewdidDisappeaar()
}


//Adding the webview here..Base viewcontroller whose child is webview

class VLViewController: UIViewController, WKUIDelegate {
    private var verloopSDK: VerloopSDK? = nil
    private var lifeCycleDelegate:VLViewControllerLifeCycleDelegate?
    
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
        self.lifeCycleDelegate = webView
    }
    private func updateWebViewConstraints() {

           webView?.webView.translatesAutoresizingMaskIntoConstraints = false

           webView?.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

           webView?.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

           webView?.webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

           webView?.webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    }
    
    func setViewControllerLifeCycleDelegate(_ delegate:VLViewControllerLifeCycleDelegate?) {
        self.lifeCycleDelegate = delegate
    }
    
    func setSDK(verloopSDK sdk: VerloopSDK) {
        verloopSDK = sdk
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "×", style: .done, target: self, action: #selector(back(_:)))
        self.lifeCycleDelegate?.VLViewControllerViewdidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: The navigationBar's display (UI Color and frame), according to the client, needs to be changed everytime user comes back to the ChatBot window.
        self.updateWebViewConstraints()
        if let sdk = verloopSDK,let status = sdk.reachability?.connection,status == .unavailable {
            let noNetworkAlert = UIAlertController(title: "Network", message: "No network connection available. Please try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                
            }
            noNetworkAlert.addAction(okAction)
            self.present(noNetworkAlert, animated: true, completion: nil)
            loader?.removeFromSuperview()
            return
        }
        
        let ready = webView?.isManagerReady() ?? false

        if !ready {
            loader = UIActivityIndicatorView(frame: CGRect(x: view.center.x, y: view.center.y, width: 30, height: 30))
            loader?.tintColor = .black
            if #available(iOS 13.0, *) {
                loader?.style = .large
            }
            loader?.center = self.view.center
            loader?.startAnimating()
            view.addSubview(loader!)
            self.lifeCycleDelegate?.VLViewControllerViewWillAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.lifeCycleDelegate?.VLViewControllerViewWillDisappear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lifeCycleDelegate?.VLViewControllerViewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifeCycleDelegate?.VLViewControllerViewdidDisappeaar()
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
