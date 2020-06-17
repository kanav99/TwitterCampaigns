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
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            let user = UserData(context: ctx)
            user.key = apiSecureInput.stringValue
            user.name = "Kanav Gupta"
            user.handle = "@kanavgupta99"
            user.followers = 45
            user.following = 150

            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            mainViewController?.user = user
            mainViewController?.twitterName.stringValue = user.name!
            mainViewController?.twitterHandle.stringValue = user.handle!
            mainViewController?.twitterFollowing.stringValue = String(user.following) + " Following"
            mainViewController?.twitterFollowers.stringValue = String(user.followers) + " Followers"
            mainViewController?.userImage.image = NSImage(named: "pika")?.oval()
        }

        mainViewController?.dismiss(self)
        mainViewController?.hideForm()
    
    }

    @IBAction func exitClicked(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
}
