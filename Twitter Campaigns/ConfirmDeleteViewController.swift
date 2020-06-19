//
//  ConfirmDeleteViewController.swift
//  Twitter Campaigns
//
//  Created by Kanav Gupta on 19/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

class ConfirmDeleteViewController: NSViewController {
    
    @IBOutlet weak var messageText: NSTextField!
    @IBOutlet weak var yesButton: NSButton!
    @IBOutlet weak var noButton: NSButton!
    
    var mainViewController: ViewController?
    
    @IBAction func yesClicked(_ sender: Any) {
        
        let campaign = mainViewController?.campaigns[(mainViewController?.tableView.selectedRow)!]
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            ctx.delete(campaign!)
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            mainViewController?.loadCampaigns()
            mainViewController?.hideForm()
        }
        mainViewController?.dismiss(self)
    }
    
    @IBAction func noClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
    
    override func viewDidLoad() {
        messageText.stringValue = "Do you really want to \"" +  (mainViewController?.campaigns[(mainViewController?.tableView.selectedRow)!].name!)!
            + "\" campaign?"
    }

}
