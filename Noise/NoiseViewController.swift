//
//  NoiseViewController.swift
//  NoiseApp
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//
import NoiseFetcher
import Cocoa
import WebKit

class NoiseViewController: NSViewController {
    @IBOutlet var quit: NSTextField!
    @IBOutlet var webViewContainer: NSView!
    var noise: Fetcher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noise = Fetcher(["https://www.apple.com", "https://www.google.com"], withDelay: 60)
        webViewContainer.addSubview(noise.view)
        noise.view.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor).isActive = true
        noise.view.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor).isActive = true
        noise.view.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        noise.view.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        noise.run()
    }
    
    @IBAction func quit(_ sender: NSButton) {
        noise.stop()
        NSApplication.shared().terminate(sender)
    }
}
