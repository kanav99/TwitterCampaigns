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
        
        let index = mainViewController?.tableView?.selectedRow
        let campaign = mainViewController?.campaigns[index!]
        let id = String(index!)
        
        let environment = [
            "VIRTUAL_ENV": mainViewController!.venvPath,
            "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES",
            "TCGUI": "YES"
        ]
        
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            ctx.delete(campaign!)
            
            if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
                let deleteProcess = Process()
                deleteProcess.launchPath = "/usr/bin/env"
                deleteProcess.environment = environment
                deleteProcess.arguments = [mainViewController!.venvPath + "/bin/python", main, "delete", "--id", id ]
                deleteProcess.launch()
                deleteProcess.waitUntilExit()
            }
            
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
