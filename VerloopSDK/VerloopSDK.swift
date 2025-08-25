//
//  Verloop.swift
//  Verloop
//
//  Created by Shobhit Bakliwal on 20/11/18.
//  Copyright © 2018 Verloop. All rights reserved.
//

import WebKit
import UIKit
import Foundation

@objc open class VerloopSDK: NSObject, VLJSInterface {
    private var config: VLConfig
    var manager: VLWebViewManager!
    private var verloopController: VLViewController? = nil
    private var verloopNavigationController: UINavigationController? = nil

    var reachability: Reachability?
    var lostNetworkConnection = false
    @objc public init(config vlConfig: VLConfig) {
        config = vlConfig
        //Storing config params in user defaults
        config.save()
        super.init()
        manager = VLWebViewManager(config: config)
        manager.jsDelegate(delegate: self)
        //Part of network reachability
        startHost(host: "verloop.io")
        getNavigationInfo()
    }
    
    deinit {
        verloopNavigationController = nil
        verloopController = nil
        config.resetConfigParams()
        stopNotifier()
    }
    
    @objc public func openWidget(rootController:UIViewController) {
        
        verloopNavigationController = getNavController()
        
        rootController.present(verloopNavigationController!, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {[weak self] in
                self?.manager.openWidget()
            }
        }
    }
   
    
    @objc public func closeWidget() {
        onChatClose {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {[weak self] in
                let hasNetwork = !((self?.reachability?.connection == .unavailable) )
                self?.manager.closeWidget(hasInternet: hasNetwork)
            }
        }
    }
    
    @objc public func close() {
        self.manager.close()
    }
    
    @objc public func observeLiveChatEventsOn(vlEventDelegate delegate:VLEventDelegate) {
        if manager != nil {
            manager.addEventChangeDelegate(delegate)
        }
    }
    
    @objc public func updateConfig(config vlConfig: VLConfig){
        config = vlConfig
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func login(){
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func login(userId uid: String){
        config.setUserId(userId: uid)
        config.save()
        manager.setConfig(config: config)
    }
    
    @objc public func logout() {
        manager.logoutSession()
        clearConfig()
        config.clearUserDetails()
    }
    
    @objc public func clearConfig(){
        config.clear()
        manager.clearConfig(config: config)
        self.config = VLConfig(clientId: "")
        self.clearLocalStorage()
    }
    @objc public func clearLocalStorage(){
        manager.clearLocalStorageVistorToken()

    }
    public func getConfig() -> VLConfig {
        return config
    }
    
    @objc public func getNavController() -> UINavigationController {
            if verloopNavigationController != nil {

                return verloopNavigationController!

            }

            verloopController = VLViewController.init(webView: manager)

            verloopController!.title = config.getNavTitle

            verloopController!.setSDK(verloopSDK: self)

            verloopNavigationController = VLNavViewController.init(rootViewController: verloopController!)

            verloopNavigationController?.navigationItem.leftItemsSupplementBackButton = true

            verloopNavigationController?.navigationItem.hidesBackButton = false

            verloopNavigationController?.navigationItem.backBarButtonItem?.isEnabled = true

            verloopNavigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

            verloopNavigationController?.hidesBarsOnSwipe = false

            verloopNavigationController?.view.backgroundColor = .white

            verloopNavigationController?.navigationBar.barTintColor = UIColor.white

            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

            UINavigationBar.appearance().shadowImage = UIImage()

            UINavigationBar.appearance().isTranslucent = true

            verloopNavigationController?.modalPresentationStyle = .fullScreen

            return verloopNavigationController!

        }
    
    //called when client information such as color cod eof the bar and title to be displayed on bar received from the live chat script
    
    func refreshClientInfo() {
        // Clear any existing title view
        verloopController?.navigationItem.titleView = nil
        
        // Create a custom title view that will expand properly
        let titleView = createExpandingTitleView()
        
        // Set the title view
        verloopController?.navigationItem.titleView = titleView
        
        // Configure navigation bar appearance
        configureNavigationBarAppearance()
        
        // Force layout update
        DispatchQueue.main.async { [weak self] in
            self?.verloopController?.navigationController?.navigationBar.layoutIfNeeded()
        }
    }

    private func createExpandingTitleView() -> UIView {
        let containerView = UIView()
        
        // Create horizontal stack for logo and text content
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.distribution = .fill
        horizontalStack.spacing = 8
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        // Add brand logo if available
        if let logoUrl = URL(string: config.getBrandLogoUrl), !config.getBrandLogoUrl.isEmpty {
            let logoImageView = UIImageView()
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            logoImageView.contentMode = .scaleAspectFill
            logoImageView.clipsToBounds = true
            // Set fixed size for logo
            NSLayoutConstraint.activate([
                logoImageView.widthAnchor.constraint(equalToConstant: 32),
                logoImageView.heightAnchor.constraint(equalToConstant: 32)
            ])
            // Make image view round
            logoImageView.layer.cornerRadius = 16
            logoImageView.layer.masksToBounds = true

            // Load image asynchronously
            URLSession.shared.dataTask(with: logoUrl) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        logoImageView.image = image
                    }
                }
            }.resume()
            
            horizontalStack.addArrangedSubview(logoImageView)
        }
        
        // Create vertical stack for title and subtitle
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.alignment = .leading
        verticalStack.distribution = .fill
        verticalStack.spacing = 2
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = config.getNavTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = config.getNavTextColor
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = config.getNavTitleAlignment
        verticalStack.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true

        // Subtitle label (if available)
        let subtitleText = config.getNavSubtitle
        if !subtitleText.isEmpty {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitleText
            subtitleLabel.font = UIFont.systemFont(ofSize: 13)
            subtitleLabel.textColor = config.getNavTextColor.withAlphaComponent(0.8)
            subtitleLabel.numberOfLines = 1
            subtitleLabel.lineBreakMode = .byTruncatingTail
            subtitleLabel.textAlignment = config.getNavSubtitleAlignment
            verticalStack.addArrangedSubview(subtitleLabel)
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.widthAnchor.constraint(equalTo: verticalStack.widthAnchor).isActive = true
        }
        
        horizontalStack.addArrangedSubview(verticalStack)
        containerView.addSubview(horizontalStack)
        
        // Key: Pin the horizontal stack to fill the entire container
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Set container height to match navigation bar
            containerView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Calculate the required width based on screen size and safe margins
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 120 // Leave space for back button and margins
        
        // Set the container width to fill available space
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: availableWidth)
        ])
        
        return containerView
    }

    private func configureNavigationBarAppearance() {
        guard let navigationController = verloopNavigationController else { return }
        
        let navigationBar = navigationController.navigationBar
        
        // Set navigation bar colors
        navigationBar.backgroundColor = config.getNavBgColor
        navigationBar.barTintColor = config.getNavBgColor
        navigationBar.isTranslucent = false
        
        // Configure back button color
        verloopController?.navigationItem.leftBarButtonItem?.tintColor = config.getNavTextColor
        navigationBar.tintColor = config.getNavTextColor
        
        // Set title text attributes (fallback for when titleView is not used)
        navigationBar.titleTextAttributes = [
            .foregroundColor: config.getNavTextColor,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        
        // Ensure the navigation bar is visible and properly styled
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
}



    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.white
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //This method executes as part of the n/w state changes and if any n/w inactive tasks to be processed then web view manager make respective functions.
    func refreshwebViewOnNetworkReconnection() {
        manager.executeNetworkChangeConfigurations()
    }

    //following is a delegate method of JsDelegate which is responsible for handling back call backs to the client app for
    //button clicks
    //url clicks
    //where as 'ready' call back is used to identify the color code of the navigation bar and title
    //below method executes when user made a selection on the webview for links / buttons
    func jsCallback(message: Any) {
       let str = message as! String
       let data = str.data(using: String.Encoding.utf8)!
       do {
            let _ =  try JSONDecoder().decode(ClientInfo.self, from: data)
           //We are no longer updating the navigation bar from this location; instead, we are updating it from the getNavigationInfo() method.
//            title = clientInfo.title
//            bgColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.bgColor)
//            textColor = VerloopSDK.hexStringToUIColor(hex: clientInfo.textColor)
//            refreshClientInfo()
            verloopController?.dismissLoader()
            manager.updateReadyState(true)
       }catch {
           print("Problem retreiving client Info")
       }
       do {
            let buttonInfo =  try JSONDecoder().decode(OnButtonClick.self, from: data)
            let title = buttonInfo.title
            let type = buttonInfo.type
            let payload = buttonInfo.payload
            config.getButtonClickListener()?(title,type, payload)
  
       }catch {
           print("Problem retreiving button Info")
       }
       do {
          let urlInfo =  try JSONDecoder().decode(OnURLClick.self, from: data)
          let url = urlInfo.url
          config.getURLClickListener()?(url)
      }catch {
          print("Problem retreiving url Info")
      }
   }
//    
//    func downloadClickListner(urlString: Any?) {
//        guard let urlString = urlString as? String, let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        let rootView = verloopNavigationController?.view
//        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
//        }
//        if let popoverController = activityViewController.popoverPresentationController {
//            popoverController.sourceView = rootView
//            popoverController.sourceRect = CGRect(x: rootView?.bounds.midX ?? 0, y: rootView?.bounds.midY ?? 0, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//        }
//        self.verloopNavigationController?.present(activityViewController, animated: true)
//    }

    @objc public func hide() {
        onChatClose {
            //nothing to do here
        }
    }
    
    func onChatClose(completion:@escaping(() -> Void)) {
        if self.verloopController != nil {
            self.verloopNavigationController?.dismiss(animated: true, completion: {
                completion()
            })
        } else {
            completion()
        }
    }
    
    //below are the 3 objects which will be prepare as part of the JSCallback delegate methods for button click, urlclick and client info
    private struct ClientInfo: Decodable {
        public let title: String
        public let bgColor: String
        public let textColor: String
    }
    
    private struct OnButtonClick: Decodable {
        public let title: String
        public let type: String
        public let payload: String
    }
    
    private struct OnURLClick: Decodable {
        public var url:String
    }
    
    //MARK: - Initiating API request to update the navigation bar's bgColor, text color, and title.
    private func getNavigationInfo() {
        let requestComponents: VLNetworkManagerRequestComponents = VLNetworkManagerRequestComponents(method: .get)
        VLNetworkManager.shared.request(url: config.getLiveChatInitUrl, requestComponents: requestComponents) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let responseData):
                guard let data = responseData else { return }
                do {
                    let response: VLClientInfoSchema? = try JSONDecoder().decode(VLClientInfoSchema.self, from: data)
                    self.config.updateClientInitInfo(response: response)
                    DispatchQueue.main.async {
                        self.refreshClientInfo()
                    }
                } catch let error {
                    print(error)
                    DispatchQueue.main.async {
                        self.refreshClientInfo()
                    }
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.refreshClientInfo()
                }
            }
        }
    }
}
