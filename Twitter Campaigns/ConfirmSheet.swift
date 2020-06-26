//
//  ConfirmSheet.swift
//  Twitter Campaigns
//
//  Created by Kanav Gupta on 26/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

class ConfirmSheet: NSViewController {
    
    @IBOutlet weak var messageLabel: NSTextField!
    var mainViewController: ViewController?
    var callback: (() -> ())?
    @IBOutlet weak var progress: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func yesClicked(_ sender: Any) {
        progress.isHidden = false
        progress.startAnimation(self)
        DispatchQueue.global().async {
            self.callback!()
            DispatchQueue.main.async {
                self.progress.stopAnimation(self)
                self.progress.isHidden = true
                self.mainViewController?.dismiss(self)
            }
        }
    }

    @IBAction func noClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }

}
