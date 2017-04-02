//
//  NoiseViewController.swift
//  NoiseApp
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//
import NoiseFetcher
import Cocoa

class NoiseViewController: NSViewController {
    let noise = Fetcher(["https://www.apple.com"], withDelay: 5)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
