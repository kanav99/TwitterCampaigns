//
//  WarningSheet.swift
//  Twitter Campaigns
//
//  Created by Kanav Gupta on 27/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

class WarningSheet: NSViewController {
    
    @IBOutlet weak var label: NSTextField!
    var mainViewController: ViewController?

    @IBAction func onClick(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
}
