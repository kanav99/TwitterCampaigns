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
    @IBOutlet weak var strategySelector: NSPopUpButton!
    
    var mainViewController: ViewController?

    @IBAction func onOkClicked(_ sender: Any) {
        if let strategy = strategySelector.titleOfSelectedItem {
            if strategy == "Most Friends First" {
                mainViewController?.addCampaign(name: campaignNameTextField.stringValue, strategy: "friend")
            }
            else if strategy == "Most Retweets First" {
                mainViewController?.addCampaign(name: campaignNameTextField.stringValue, strategy: "tweet")
            }
            else if strategy == "Most Followers First" {
                mainViewController?.addCampaign(name: campaignNameTextField.stringValue, strategy: "follower")
            }
        }
        mainViewController?.dismiss(self)
    }

    
    @IBAction func onCancelClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
}
