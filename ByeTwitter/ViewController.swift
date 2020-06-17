//
//  ViewController.swift
//  ByeTwitter
//
//  Created by Kanav Gupta on 16/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa


class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var campaigns: [Campaign] = []
    var isLoggedIn: Bool = false

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var userImage: NSImageView!
    @IBOutlet weak var twitterName: NSTextField!
    @IBOutlet weak var twitterHandle: NSTextField!
    @IBOutlet weak var twitterFollowers: NSTextField!
    @IBOutlet weak var twitterFollowing: NSTextField!
    
    @IBOutlet weak var loginButton: NSButton!
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.presentAsSheet(firstTimeSetupSheet)
    }
    
    @IBOutlet weak var addCampaignButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var campaignNameLabel: NSTextField!
    @IBOutlet weak var campaignNameTextField: NSTextField!
    @IBOutlet weak var strategyLabel: NSTextField!
    @IBOutlet weak var strategyPopUpButton: NSPopUpButton!
    @IBOutlet weak var messageTextLabel: NSTextField!
    @IBOutlet weak var messageTextTextField: NSTextField!
    @IBOutlet weak var deleteCampaignButton: NSButton!
    
    lazy var campaignNameInputSheet: CampaignNameInputSheet = {
        var sheet = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("CampaignNameInputSheet"))
        as! CampaignNameInputSheet
        sheet.mainViewController = self
        return sheet
    }()
    
    lazy var firstTimeSetupSheet: FirstTimeSetupController = {
        var sheet = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("firstTimeSetup"))
        as! FirstTimeSetupController
        sheet.mainViewController = self
        return sheet
    }()
    
    func loadCampaigns() {
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            do {
                campaigns = try ctx.fetch(Campaign.fetchRequest())
            }
            catch {}
        }
        tableView.reloadData()
    }

    func loadUserData() {
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            do {

                let data: [UserData] = try ctx.fetch(UserData.fetchRequest())

                if data.count == 0 {
                    twitterName.isHidden = true
                    twitterHandle.isHidden = true
                    twitterFollowers.isHidden = true
                    twitterFollowing.isHidden = true
                    isLoggedIn = false
                    addCampaignButton.isHidden = true

                    loginButton.isHidden = false
                }
                else {
                    twitterName.stringValue = data[0].name!
                    twitterHandle.stringValue = data[0].handle!
                    twitterFollowing.stringValue = String(data[0].following) + " Following"
                    twitterFollowers.stringValue = String(data[0].followers) + " Followers"
                    isLoggedIn = true
                }
            }
            catch {}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        userImage.image = NSImage(named: "pika")?.oval()
        userImage.layer?.masksToBounds = true
        userImage.layer?.cornerRadius = 0.0// userImage.bounds.width / 2.0
        
        twitterName.stringValue = "Kanav Gupta"
        twitterHandle.stringValue = "@kanavgupta99"
        twitterFollowing.stringValue = "182 Following"
        twitterFollowers.stringValue = "45 Followers"
        
        loadUserData()
        if isLoggedIn {
            loadCampaigns()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - TableView Code
    func numberOfRows(in tableView: NSTableView) -> Int {
        return campaigns.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "campaignCell"), owner: self) as? CampaignListItemCell {
            
            cell.progressIndicator.doubleValue = campaigns[row].progress
            cell.campaignNameLabel.stringValue = campaigns[row].name!
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if isLoggedIn {
            if tableView.selectedRow == -1 {
                hideForm()
            } else {
                showForm()
            }
        }
    }
    
    // MARK: - button helpers
    
    func showForm() {
        userImage.isHidden = true
        twitterName.isHidden = true
        twitterHandle.isHidden = true
        twitterFollowers.isHidden = true
        twitterFollowing.isHidden = true
        
        startButton.isHidden = false
        pauseButton.isHidden = false
        campaignNameLabel.isHidden = false
        campaignNameTextField.isHidden = false
        strategyLabel.isHidden = false
        strategyPopUpButton.isHidden = false
        messageTextLabel.isHidden = false
        messageTextTextField.isHidden = false
        deleteCampaignButton.isHidden = false
        
        let index = tableView.selectedRow
        campaignNameTextField.stringValue = campaigns[index].name!
    }
    
    func hideForm() {
        userImage.isHidden = false
        twitterName.isHidden = false
        twitterHandle.isHidden = false
        twitterFollowers.isHidden = false
        twitterFollowing.isHidden = false
        
        startButton.isHidden = true
        pauseButton.isHidden = true
        campaignNameLabel.isHidden = true
        campaignNameTextField.isHidden = true
        strategyLabel.isHidden = true
        strategyPopUpButton.isHidden = true
        messageTextLabel.isHidden = true
        messageTextTextField.isHidden = true
        deleteCampaignButton.isHidden = true
    }

    @IBAction func newCampaign(_ sender: Any) {
   
        self.presentAsSheet(campaignNameInputSheet)
    }
    
    func addCampaign(name: String) {
        if name != "" {
            if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {

                let campaign = Campaign(context: ctx)
                campaign.name = name
                campaign.progress = 0.0

                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                loadCampaigns()
            }
        }
    }
    
    @IBAction func deleteCampaignClicked(_ sender: Any) {
        let campaign = campaigns[tableView.selectedRow]
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            ctx.delete(campaign)
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            loadCampaigns()
            hideForm()
        }
        
    }
    
}

extension NSImage {

    /// Copies this image to a new one with a circular mask.
    func oval() -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()

        NSGraphicsContext.current?.imageInterpolation = .high
        let frame = NSRect(origin: .zero, size: size)
        NSBezierPath(ovalIn: frame).addClip()
        draw(at: .zero, from: frame, operation: .sourceOver, fraction: 1)

        image.unlockFocus()
        return image
    }
}
