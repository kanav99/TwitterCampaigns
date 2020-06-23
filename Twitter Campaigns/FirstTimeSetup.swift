//
//  FirstTimeSetup.swift
//  ByeTwitter
//
//  Created by Kanav Gupta on 17/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

struct UserJSON: Decodable {
    let name: String
    let followers_count: Int64
    let friends_count: Int64
    let screen_name: String
    let profile_image_url_https: String
}

class FirstTimeSetupController: NSViewController {
    
    @IBOutlet weak var consumerKeyInput: NSSecureTextField!
    @IBOutlet weak var consumerSecretInput: NSSecureTextField!
    @IBOutlet weak var accessKeyInput: NSSecureTextField!
    @IBOutlet weak var accessSecretInput: NSSecureTextField!
    
    @IBOutlet weak var invalidLabel: NSTextField!
    @IBOutlet weak var cautionIcon: NSImageView!

    var mainViewController: ViewController?
    
    @IBAction func okClicked(_ sender: Any) {
        // TODO: - Login Logic goes here
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            let consumerKey = consumerKeyInput.stringValue
            let consumerSecret = consumerSecretInput.stringValue
            let accessKey = accessKeyInput.stringValue
            let accessSecret = accessSecretInput.stringValue
            
            if let twitterpy = Bundle.main.path(forResource: "twitter", ofType: "py") {
                let pythonProcess = Process()
                pythonProcess.launchPath = "/usr/bin/env"
                pythonProcess.arguments = [mainViewController!.venvPath + "/bin/python", twitterpy]
                pythonProcess.environment = [
                    "VIRTUAL_ENV": mainViewController!.venvPath,
                    "TCConsumerKey": consumerKey,
                    "TCConsumerSecret": consumerSecret,
                    "TCAccessKey": accessKey,
                    "TCAccessSecret": accessSecret
                ]
                let pipe = Pipe()
                pythonProcess.standardOutput = pipe
                pythonProcess.launch()
                pythonProcess.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                do {
                    let authUser: UserJSON = try JSONDecoder().decode(UserJSON.self, from: data)
                    let user = UserData(context: ctx)
                    user.key = consumerKeyInput.stringValue
                    user.name = authUser.name
                    user.handle = authUser.screen_name
                    user.followers = authUser.followers_count
                    user.following = authUser.friends_count
                    user.image = authUser.profile_image_url_https.replacingOccurrences(of: "_normal", with: "")
                        
                    (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                    
                    mainViewController?.user = user
                    mainViewController?.twitterName.stringValue = user.name!
                    mainViewController?.twitterHandle.stringValue = "@" + user.handle!
                    mainViewController?.twitterFollowing.stringValue = String(user.following) + " Following"
                    mainViewController?.twitterFollowers.stringValue = String(user.followers) + " Followers"
                    mainViewController?.userImage.image = NSImage(contentsOf: URL(string: authUser.profile_image_url_https.replacingOccurrences(of: "_normal", with: ""))!)?.oval()
                    
                    mainViewController?.dismiss(self)
                    mainViewController?.hideForm()
                }
                catch {
                    cautionIcon.isHidden = false
                    invalidLabel.isHidden = false
                }
            }
            
        }
    }

    @IBAction func exitClicked(_ sender: Any) {
        cautionIcon.isHidden = true
        invalidLabel.isHidden = true
        mainViewController?.dismiss(self)
    }
}
