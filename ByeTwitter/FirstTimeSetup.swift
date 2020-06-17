//
//  FirstTimeSetup.swift
//  ByeTwitter
//
//  Created by Kanav Gupta on 17/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

class FirstTimeSetupController: NSViewController {
    
    @IBOutlet weak var apiSecureInput: NSSecureTextField!
    var mainViewController: ViewController?
    
    @IBAction func okClicked(_ sender: Any) {
        // TODO: - Login Logic goes here
        
        mainViewController?.dismiss(self)
        mainViewController?.isLoggedIn = true
        mainViewController?.loadCampaigns()
        mainViewController?.hideForm()
        mainViewController?.loginButton.isHidden = true
    }

    @IBAction func exitClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
        exit(0)
    }
}
