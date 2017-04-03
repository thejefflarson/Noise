//
//  Fetcher.swift
//  Noise
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//

import Foundation
import WebKit

class Loader: NSObject, WKNavigationDelegate {
    private var done: (UInt64) -> ()
    var view: WKWebView
    override init() {
        let config = WKWebViewConfiguration()
        if #available(macOS 10.11, iOS 9.0, *) {
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        view = WKWebView(frame: CGRect(x: 0, y: 0, width: 460, height: 320), configuration: config)
        self.done = {(it) in ()}
    }
    
    func load(_ url: String, _ callback: @escaping (UInt64) -> ()) {
        if let parsed = URL(string: url) {
            view.navigationDelegate = self
            view.load(URLRequest(url: parsed))
            done = callback
        } else {
            done(0)
        }
    }
    
    func webView(_ view: WKWebView, didFinish navigation: WKNavigation) {
        view.evaluateJavaScript("document.firstElementChild.outerHTML.length") { (maybe, error) in
            switch maybe {
            case let length as UInt64:
                self.done(length)
            default:
                self.done(0)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.done(0)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.done(0)
    }
}

class Fetcher : NSObject {
    private var urls: [String]
    private var loader: Loader
    private var running: Bool = false
    var delay: UInt32
    var count: UInt64 = 0
    var last: UInt64 = 0
    dynamic var bytes: UInt64 = 0
    
    init(_ urls: [String], withDelay delay: UInt32) {
        self.urls = urls
        self.loader = Loader()
        self.delay = delay
    }
    
    func run() {
        self.running = true
        go()
    }
    
    func stop() {
        self.running = false
    }
    
    var view: WKWebView {
        return loader.view
    }
    
    private func next(_  bytes: UInt64) {
        self.count += 1
        self.last = bytes
        self.bytes += bytes
        let rand = arc4random_uniform(self.delay) + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(rand), execute: {
            if(self.running) {
                self.go()
            }
        })
    }
    
    private func go() {
        let index = Int(arc4random_uniform(UInt32(self.urls.count)))
        self.loader.load(self.urls[index], self.next)
    }
}


