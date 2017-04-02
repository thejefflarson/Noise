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
}

class Fetcher : NSObject {
    private var urls: [String]
    private var loader: Loader
    private var index: Int
    private var running: Bool
    private var delay: UInt32
    private var stats: Stats
    init(_ urls: [String], withDelay delay: UInt32) {
        self.urls = urls
        self.index = 0
        self.loader = Loader()
        self.running = false
        self.stats = Stats()
        self.delay = delay
    }
    
    func run() {
        self.running = true
        loader.load(urls[0], next)
    }
    
    func stop() {
        self.running = false
    }
    
    var bytes: UInt64 {
        return stats.bytes
    }
    
    var hosts: Set<String> {
        return stats.hosts
    }
    
    var visited: UInt64 {
        return stats.count
    }
    
    var view: WKWebView {
        return loader.view
    }
    
    private func next(_  bytes: UInt64) {
        self.stats.incBytes(by: bytes)
        self.stats.incCount(by: 1)
        self.stats.addUrl(url: self.urls[0])
        let rand = arc4random_uniform(self.delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(rand), execute: {
            if(self.running) {
                self.index += 1
                self.loader.load(self.urls[self.index % self.urls.count], self.next)
            }
        })
    }
}

class Stats {
    public private(set) var bytes: UInt64
    public private(set) var count: UInt64
    public private(set) var hosts: Set<String>
    public private(set) var started: Date
    
    init() {
        bytes = 0
        count = 0
        hosts = []
        started = Date()
    }
    
    func incBytes(by: UInt64) {
        bytes += by
    }
    
    func incCount(by: UInt64) {
        count += by
    }
    
    func addUrl(url: String) {
        if let parsed = URL(string: url) {
            if hosts.count > 5 { hosts.removeFirst() }
            if let host = parsed.host {
                hosts.insert(host)
            }
        }
    }
}
