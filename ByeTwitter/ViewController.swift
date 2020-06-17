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
    var user: UserData!

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var banner: NSTextField!
    @IBOutlet weak var userImage: NSImageView!
    @IBOutlet weak var twitterName: NSTextField!
    @IBOutlet weak var twitterHandle: NSTextField!
    @IBOutlet weak var twitterFollowers: NSTextField!
    @IBOutlet weak var twitterFollowing: NSTextField!
    
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var logoutButton: NSButton!
    
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
                    noUserMode()
                }
                else {
                    hideForm()
                    user = data[0]
                    twitterName.stringValue = data[0].name!
                    twitterHandle.stringValue = data[0].handle!
                    twitterFollowing.stringValue = String(data[0].following) + " Following"
                    twitterFollowers.stringValue = String(data[0].followers) + " Followers"
                    userImage.image = NSImage(named: "pika")?.oval()
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
        
        loadUserData()
        loadCampaigns()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: - TableView Code
    func numberOfRows(in tableView: NSTableView) -> Int {
        return isLoggedIn ? campaigns.count : 0
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
    
    // MARK: - Modes
    
    func showForm() {
        userImage.isHidden = true
        twitterName.isHidden = true
        twitterHandle.isHidden = true
        twitterFollowers.isHidden = true
        twitterFollowing.isHidden = true
        logoutButton.isHidden = true
        
        startButton.isHidden = false
        pauseButton.isHidden = false
        campaignNameLabel.isHidden = false
        campaignNameTextField.isHidden = false
        strategyLabel.isHidden = false
        strategyPopUpButton.isHidden = false
        messageTextLabel.isHidden = false
        messageTextTextField.isHidden = false
        deleteCampaignButton.isHidden = false
        
        loginButton.isHidden = true
        addCampaignButton.isHidden = false
        isLoggedIn = true
        banner.isHidden = true
        
        let index = tableView.selectedRow
        campaignNameTextField.stringValue = campaigns[index].name!
    }
    
    func hideForm() {
        userImage.isHidden = false
        twitterName.isHidden = false
        twitterHandle.isHidden = false
        twitterFollowers.isHidden = false
        twitterFollowing.isHidden = false
        logoutButton.isHidden = false
        
        startButton.isHidden = true
        pauseButton.isHidden = true
        campaignNameLabel.isHidden = true
        campaignNameTextField.isHidden = true
        strategyLabel.isHidden = true
        strategyPopUpButton.isHidden = true
        messageTextLabel.isHidden = true
        messageTextTextField.isHidden = true
        deleteCampaignButton.isHidden = true
        
        loginButton.isHidden = true
        addCampaignButton.isHidden = false
        isLoggedIn = true
        banner.isHidden = true
    }
    
    func noUserMode() {
        userImage.isHidden = false
        twitterName.isHidden = true
        twitterHandle.isHidden = true
        twitterFollowers.isHidden = true
        twitterFollowing.isHidden = true
        logoutButton.isHidden = true

        startButton.isHidden = true
        pauseButton.isHidden = true
        campaignNameLabel.isHidden = true
        campaignNameTextField.isHidden = true
        strategyLabel.isHidden = true
        strategyPopUpButton.isHidden = true
        messageTextLabel.isHidden = true
        messageTextTextField.isHidden = true
        deleteCampaignButton.isHidden = true
        
        loginButton.isHidden = false
        addCampaignButton.isHidden = true
        isLoggedIn = false
        user = nil
        banner.isHidden = false
        
        tableView.reloadData()
        
        userImage.image = NSImage(named: "twitter")?.oval()
    }

    // MARK: - Button Handlers
    @IBAction func newCampaignClicked(_ sender: Any) {
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
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.presentAsSheet(firstTimeSetupSheet)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            
            ctx.delete(user)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: Campaign.fetchRequest())
            do {
                try ctx.execute(deleteRequest)
            }
            catch {}
            (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
            
            noUserMode()
        }
    }
    
}

