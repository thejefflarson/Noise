//
//  NoiseViewController.swift
//  NoiseApp
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//
import Cocoa
import WebKit

class NoiseViewController: NSViewController {
    @IBOutlet var webViewContainer: NSView!
    @IBOutlet var label: NSTextField!
    var noise: Fetcher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        noise.addObserver(self, forKeyPath: #keyPath(Fetcher.bytes), options: .new, context: nil)
        update()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Fetcher.bytes) {
            update()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func addView() {
        webViewContainer.addSubview(noise.view)
        noise.view.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor).isActive = true
        noise.view.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor).isActive = true
        noise.view.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        noise.view.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
    }
    
    private func update() {
        if webViewContainer.subviews[0] != noise.view {
            webViewContainer.subviews[0].removeFromSuperview()
            addView()
        }
        let bytes = ByteCountFormatter.string(fromByteCount: Int64(noise.bytes), countStyle: ByteCountFormatter.CountStyle.file)
        let s = noise.count != 1 ? "s" : ""
        label.stringValue = "Loaded \(noise.count) site\(s): \(bytes)"
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
}
