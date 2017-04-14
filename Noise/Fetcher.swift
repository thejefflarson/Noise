//
//  Fetcher.swift
//  Noise
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//

import Foundation
import WebKit

struct FetcherHost {
    var host: String
    var cumsum: Double
    init?(_ row: String) {
        if row.isEmpty { return nil }
        let bits = row.characters.split(separator: "\t")
        host = String(bits[1])
        cumsum = Double(String(bits[0]))!
    }
}

class Loader: NSObject, WKNavigationDelegate {
    private var done: (UInt64) -> ()
    let width: CGFloat = 800
    let height: CGFloat = 600
    var view: WKWebView
    override init() {
        let config = WKWebViewConfiguration()
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
        config.preferences.javaEnabled = false
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.preferences.plugInsEnabled = false
        config.applicationNameForUserAgent = "Version/10.1 Safari/603.1.30"
        view = WKWebView(frame: CGRect(x: 0, y: 0, width: width, height: height), configuration: config)
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
                self.resize()
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
    
    let fudge = 200
    private func resize() {
        var f = view.frame
        f.size.width = width + CGFloat(Int(arc4random_uniform(UInt32(fudge))) - fudge / 2)
        f.size.height = height + CGFloat(Int(arc4random_uniform(UInt32(fudge))) - fudge / 2)
        view.frame = f
    }
}

// GameKit's too silly for this purpose
class Guassian {
    private var mean: Double
    private var deviation: Double
    private var value: Double?
    
    init(mean: Double, deviation: Double) {
        self.mean = mean
        self.deviation = deviation
    }
    
    var rand : Double {
        if let ret = value {
            value = nil
            return ret * deviation + mean
        } else {
            var u, v, s: Double
            repeat {
                u = randRange()
                v = randRange()
                s = u*u + v*v
            } while s == 0 || s >= 1
            let root = sqrt(-2 * log(s) / s)
            value = u * root
            return v * root * deviation + mean
        }
    }
    
    private func randRange() -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * 2 - 1
    }
}

class Fetcher : NSObject {
    private var urls: [FetcherHost]
    private var loader: Loader
    private var running: Bool = false
    private var gauss: Guassian
    var delay: Double
    var count: UInt64 = 0
    var last: UInt64 = 0
    dynamic var bytes: UInt64 = 0
    
    init(_ urls: [String], withDelay delay: Double) {
        self.urls = urls.map { FetcherHost($0) }.flatMap { $0 }
        self.loader = Loader()
        self.delay = delay
        self.gauss = Guassian(mean: delay, deviation: delay / 2)
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
        if(bytes > 0) {
            self.count += 1
            self.last = bytes
            self.bytes += bytes
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + gauss.rand, execute: {
            if(self.running) {
                self.go()
            }
        })
    }
    
    private let maxSize = 1000000
    private func go() {
        // WKWebView is very very leaky let's let 10 requests go by before we kill the subprocess.
        if self.count % 50 == 0 {
            self.loader = Loader()
        }
        let prob = Double(arc4random_uniform(UInt32(maxSize))) / Double(maxSize)
        var index = 0
        while(self.urls[index].cumsum < prob && index < self.urls.count) { index += 1 }
        self.loader.load(self.urls[index].host, self.next)
    }
}


