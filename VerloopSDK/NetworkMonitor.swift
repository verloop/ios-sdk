//
//  ReachabilityHandler.swift
//  VerloopSDK
//
//  Created by sreedeep on 14/03/22.
//  Copyright © 2022 Verloop. All rights reserved.
//

import Foundation

extension VerloopSDK {
    
    func startHost(host:String) {
        stopNotifier()
        setupReachability(host, useClosures: true)
        startNotifier()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.startHost(host:"google.com")
//        }
    }
    
    func startNotifier() {
            print("--- start notifier")
            do {
                try reachability?.startNotifier()
            } catch {
                return
            }
        }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability: Reachability?
        if let hostName = hostName {
            reachability = try? Reachability(hostname: hostName)
        } else {
            reachability = try? Reachability()
        }
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.updateLabelColourWhenReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.updateLabelColourWhenNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(reachabilityChanged(_:)),
                name: .reachabilityChanged,
                object: reachability
            )
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    func updateLabelColourWhenReachable(_ reachability: Reachability) {
//        print("\(reachability.description) - \(reachability.connection)")
        if lostNetworkConnection {
//            showNoNetworkBanner(isActive: true)
            refreshwebViewOnNetworkReconnection()
        }
        lostNetworkConnection = false
    }
    
    func updateLabelColourWhenNotReachable(_ reachability: Reachability) {
//        print("\(reachability.description) - \(reachability.connection)")
        if lostNetworkConnection {
            //no need to show banner again
        } else {
//            showNoNetworkBanner(isActive: false)
//            stopNotifier()
        }
        lostNetworkConnection = true
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            updateLabelColourWhenReachable(reachability)
        } else {
            updateLabelColourWhenNotReachable(reachability)
        }
    }

    private func showNoNetworkBanner(isActive:Bool){

        if let banner = bannerView,banner.superview != nil {
            bannerView?.removeFromSuperview()
        }
        
        // create a "container" view
        let container = UIView()
        
        // create a label
        let label = UILabel()
        
        // add label to container
        container.addSubview(label)
        
        // color / font / text properties as desired
        container.backgroundColor = isActive ? UIColor.green : UIColor.red
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "No network connection is available."
        label.textColor = .white
        label.textAlignment = .center
        
        // padding on left/right of label
        let hPadding: CGFloat = 16.0
        
        // padding on top of label - account for status bar?
        let vTopPadding: CGFloat = 32.0
        
        // padding on bottom of label
        let vBotPadding: CGFloat = 16.0

        let width = UIScreen.main.bounds.width
        
        // get reference to window 0
        let w = UIApplication.shared.windows[0]
        
        // add container to window
        w.addSubview(container)
        
        // calculate label height
        let labelSize = label.systemLayoutSizeFitting(CGSize(width: width - (hPadding * 2.0),
                                                      height: UIView.layoutFittingCompressedSize.height))
        
        // rect for container view - start with .zero
        var containerRect = CGRect.zero
        // set its size to screen width x calculated label height + top/bottom padding
        containerRect.size = CGSize(width: width, height: labelSize.height + vTopPadding + vBotPadding)
        // set container view's frame
        container.frame = containerRect
        
        // rect for label - container rect inset by padding values
        let labelRect = containerRect.inset(by: UIEdgeInsets(top: vTopPadding, left: hPadding, bottom: vBotPadding, right: hPadding))
        // set the label's frame
        label.frame = labelRect

        // position container view off-the-top of the screen
        container.frame.origin.y = -container.frame.size.height
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                container.frame.origin.y = 0
            }) { (finished) in
                UIView.animate(withDuration: 0.5,delay: 2.0, options: .curveLinear, animations: {
                    container.frame.origin.y = -container.frame.size.height
                })
            }
        }
        bannerView = container
    }
}
