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
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    
    var mainViewController: ViewController?

    @IBAction func onOkClicked(_ sender: Any) {
        okButton.isEnabled = false
        cancelButton.isEnabled = false
        progress.isHidden = false
        progressLabel.isHidden = false
        progress.startAnimation(self)
        if let strategy = self.strategySelector.titleOfSelectedItem {
            let campaignName = self.campaignNameTextField.stringValue
            DispatchQueue.global().async {
                if strategy == "Most Friends First" {
                    self.mainViewController?.addCampaign(name: campaignName, strategy: "friend")
                }
                else if strategy == "Most Retweets First" {
                    self.mainViewController?.addCampaign(name: campaignName, strategy: "tweet")
                }
                else if strategy == "Most Followers First" {
                    self.mainViewController?.addCampaign(name: campaignName, strategy: "follower")
                }
                DispatchQueue.main.async {
                    self.okButton.isEnabled = true
                    self.cancelButton.isEnabled = true
                    self.progress.isHidden = true
                    self.progressLabel.isHidden = true
                    self.progress.stopAnimation(self)
                    self.mainViewController?.dismiss(self)
                }
            }
        }
    }

    
    @IBAction func onCancelClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
}
