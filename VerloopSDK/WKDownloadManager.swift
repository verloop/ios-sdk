//
//  WKDownloadManager.swift
//  VerloopSDK
//
//  Created by Pankaj Patel on 23/08/24.
//  Copyright © 2024 Verloop. All rights reserved.
//

import Foundation
import Foundation
import WebKit


public class WKDownloadManager: NSObject {
    
    weak var delegate: WKDownloadManagerDelegate?
    
    fileprivate var downloadDestinationURL: URL?
    
    /// An array of supported Mime types.
    fileprivate var supportedMimeTypes: [String] = []
    
    
    /// Create the WKDownloadManager with a delegate and supported mime types
    /// - Parameters:
    ///   - delegate: delegate object
    ///   - supportedMimeTypes: Array of supported Mime types.
    public init(delegate: WKDownloadManagerDelegate,
                supportedMimeTypes: [String]) {
        super.init()
        self.delegate = delegate
        self.supportedMimeTypes = supportedMimeTypes
    }
    
    fileprivate func isSupported(mimeType: String) -> Bool {
        return supportedMimeTypes.contains(mimeType)
    }
    
}

public protocol WKDownloadManagerDelegate: AnyObject {
    
    func webView(_ webView: WKWebView, decidePolicyFor url: URL) -> Bool
   
    func destinationUrlForFile(withName name: String) -> URL?
    
    func downloadDidFinish(location url: URL)
    
    func downloadDidFailed(withError error: Error)
    
}

extension WKDownloadManagerDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor url: URL) -> Bool {
        return true
    }
    
    public func destinationUrlForFile(withName name: String) -> URL? {
        let temporaryDir = NSTemporaryDirectory()
        let url = URL(fileURLWithPath: temporaryDir)
            .appendingPathComponent(UUID().uuidString)
        
        if ((try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)) == nil) {
            return nil
        }
        
        return url.appendingPathComponent(name)
    }
    
    public func downloadDidFailed(withError error: Error) {
        print("File Downlaod : \(error.localizedDescription)")
    }
}


// MARK: - WKDownloadDelegate
@available(iOS 13.0.0, *)
extension WKDownloadManager: WKDownloadDelegate {
    
    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String) async -> URL? {
        downloadDestinationURL = delegate?.destinationUrlForFile(withName: suggestedFilename)
        return downloadDestinationURL
    }
    
    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        delegate?.downloadDidFailed(withError: error)
    }
    
    @available(iOS 14.5, *)
    public func downloadDidFinish(_ download: WKDownload) {
        
        if let url = downloadDestinationURL {
            delegate?.downloadDidFinish(location: url)
        }
    }
}

// MARK: - WKNavigationDelegate
@available(iOS 13.0.0, *)
extension WKDownloadManager: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        
        guard let url = navigationAction.request.url else {
            return .cancel
        }
        let isSafe: Bool = delegate?.webView(webView, decidePolicyFor: url) ?? true
        return isSafe ? .allow : .cancel
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        guard let url = navigationResponse.response.url else {
            return .cancel
        }
        
        let isSafe: Bool = delegate?.webView(webView, decidePolicyFor: url) ?? true
        if !isSafe {
            return .cancel
        } else if let mimeType = navigationResponse.response.mimeType,
                  isSupported(mimeType: mimeType) {
            if #available(iOS 14.5, *) {
                return .download
            } else {
                return .cancel
            }
        } else {
            return .allow
        }
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
}
