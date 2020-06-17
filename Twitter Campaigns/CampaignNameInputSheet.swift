//
//  CampaignNameInputSheet.swift
//  ByeTwitter
//
//  Created by Kanav Gupta on 17/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

class CampaignNameInputSheet: NSViewController {
    
    @IBOutlet weak var campaignNameTextField: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!

    var mainViewController: ViewController?

    @IBAction func onOkClicked(_ sender: Any) {
        mainViewController?.addCampaign(name: campaignNameTextField.stringValue)
        mainViewController?.dismiss(self)
    }

    
    @IBAction func onCancelClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
}
