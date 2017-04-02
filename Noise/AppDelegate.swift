//
//  AppDelegate.swift
//  NoiseApp
//
//  Created by Jeff Larson on 4/1/17.
//  Copyright © 2017 Jeff Larson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let popover = NSPopover()
    let status = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var noise: Fetcher!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = status.button {
            button.image = NSImage(named: "noise")
            button.action = #selector(toggle)
        }

        let path = Bundle.main.path(forResource: "sites", ofType: "txt")!
        let urls = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
        self.noise = Fetcher(urls.components(separatedBy: "\n"), withDelay: 60)
        let controller = NoiseViewController(nibName: "NoiseViewController", bundle: nil)!
        controller.noise = noise
        popover.contentViewController = controller
        noise.run()
    }
    
    func toggle(sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = status.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        noise.stop()
    }
}

