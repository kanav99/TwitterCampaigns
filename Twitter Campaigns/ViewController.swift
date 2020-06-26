//
//  ViewController.swift
//  ByeTwitter
//
//  Created by Kanav Gupta on 16/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

struct StatusJSON: Decodable {
    let started: Bool
    let total: Int64
    let sent: Int64
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var campaigns: [Campaign] = []
    var isLoggedIn: Bool = false
    var user: UserData!
    var venvPath: String = ""

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
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var campaignNameLabel: NSTextField!
    @IBOutlet weak var campaignNameTextField: NSTextField!
    @IBOutlet weak var strategyLabel: NSTextField!
    @IBOutlet weak var strategyPopUpButton: NSPopUpButton!
    @IBOutlet weak var messageTextLabel: NSTextField!
    @IBOutlet weak var messageTextTextField: NSTextField!
    @IBOutlet weak var deleteCampaignButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var durationDatePicker: NSDatePicker!

    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var statusResultLabel: NSTextField!
    @IBOutlet weak var refreshingStatusLabel: NSTextField!
    @IBOutlet weak var refreshingStatusLoader: NSProgressIndicator!
    
    
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
    
    lazy var deleteConfirmSheet: ConfirmDeleteViewController = {
        var sheet = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("confirmDelete"))
        as! ConfirmDeleteViewController
        sheet.mainViewController = self
        return sheet
    }()
    
    lazy var confirmSheet: ConfirmSheet = {
        var sheet = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("ConfirmSheet"))
        as! ConfirmSheet
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
                    twitterHandle.stringValue = "@" + data[0].handle!
                    twitterFollowing.stringValue = String(data[0].following) + " Following"
                    twitterFollowers.stringValue = String(data[0].followers) + " Followers"
                    userImage.image = NSImage(contentsOf: URL(string: data[0].image!)!)?.oval()
                    isLoggedIn = true
                }
            }
            catch {}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmSheet.loadView()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        loadUserData()
        loadCampaigns()
        install_pip_dependencies()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func install_pip_dependencies() {
        let homeDirectory = NSHomeDirectory()
        venvPath = homeDirectory + "/.tccli/venv"
        let requirementsTxtFile = Bundle.main.path(forResource: "requirements", ofType: "txt")!
        print(venvPath)
        let b = FileManager.default.fileExists(atPath: venvPath)
        if !b {
            let venvProcess = Process()
            venvProcess.launchPath = "/usr/bin/env"
            venvProcess.arguments = ["python3", "-m", "venv", venvPath]
            venvProcess.launch()
            venvProcess.waitUntilExit()
            
            let pipProcess = Process()
            pipProcess.launchPath = "/usr/bin/env"
            pipProcess.environment = ["VIRTUAL_ENV": venvPath]
            pipProcess.arguments = [venvPath + "/bin/pip", "install", "-r", requirementsTxtFile]
            pipProcess.launch()
            pipProcess.waitUntilExit()
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
                refreshClicked(self)
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
        resetButton.isHidden = false
        refreshButton.isHidden = false
        statusLabel.isHidden = false
        statusResultLabel.isHidden = false
        campaignNameLabel.isHidden = false
        campaignNameTextField.isHidden = false
        strategyLabel.isHidden = false
        strategyPopUpButton.isHidden = false
        messageTextLabel.isHidden = false
        messageTextTextField.isHidden = false
        deleteCampaignButton.isHidden = false
        saveButton.isHidden = false
        durationLabel.isHidden = false
        durationDatePicker.isHidden = false
        
        loginButton.isHidden = true
        addCampaignButton.isHidden = false
        isLoggedIn = true
        banner.isHidden = true
        
        let index = tableView.selectedRow
        campaignNameTextField.stringValue = campaigns[index].name!
        messageTextTextField.stringValue = campaigns[index].messageTemplate ?? ""
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
        resetButton.isHidden = true
        refreshButton.isHidden = true
        statusLabel.isHidden = true
        statusResultLabel.isHidden = true
        campaignNameLabel.isHidden = true
        campaignNameTextField.isHidden = true
        strategyLabel.isHidden = true
        strategyPopUpButton.isHidden = true
        messageTextLabel.isHidden = true
        messageTextTextField.isHidden = true
        deleteCampaignButton.isHidden = true
        saveButton.isHidden = true
        durationLabel.isHidden = true
        durationDatePicker.isHidden = true
        
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
        resetButton.isHidden = true
        refreshButton.isHidden = true
        statusLabel.isHidden = true
        statusResultLabel.isHidden = true
        campaignNameLabel.isHidden = true
        campaignNameTextField.isHidden = true
        strategyLabel.isHidden = true
        strategyPopUpButton.isHidden = true
        messageTextLabel.isHidden = true
        messageTextTextField.isHidden = true
        deleteCampaignButton.isHidden = true
        saveButton.isHidden = true
        durationLabel.isHidden = true
        durationDatePicker.isHidden = true
        
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
                
                let index = campaigns.count - 1
                let strategy = "follower"
                let id = String(index)
                let message = ""
                let environment = [
                    "VIRTUAL_ENV": venvPath,
                    "ConsumerKey": user.consumerKey!,
                    "ConsumerSecret": user.consumerSecret!,
                    "AccessKey": user.accesskey!,
                    "AccessSecret": user.accessSecret!,
                    "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES"
                ]
                
                if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
                    let deleteProcess = Process()
                    deleteProcess.launchPath = "/usr/bin/env"
                    deleteProcess.environment = environment
                    deleteProcess.arguments = [venvPath + "/bin/python", main, "delete", "--id", id ]
                    deleteProcess.launch()
                    deleteProcess.waitUntilExit()

                    let addProcess = Process()
                    addProcess.launchPath = "/usr/bin/env"
                    addProcess.environment = environment
                    addProcess.arguments = [venvPath + "/bin/python", main, "add", "--id", id, "--name", name, "--strategy", strategy, "--message", message]
                    addProcess.launch()
                    addProcess.waitUntilExit()
                }
                
                tableView?.selectRowIndexes([campaigns.count - 1], byExtendingSelection: false)

            }
        }
    }
    
    @IBAction func deleteCampaignClicked(_ sender: Any) {
        if deleteConfirmSheet.messageText != nil {
            deleteConfirmSheet.messageText.stringValue = "Do you really want to \"" + campaigns[tableView.selectedRow].name! + "\" campaign?"
        }
        self.presentAsSheet(deleteConfirmSheet)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        self.presentAsSheet(firstTimeSetupSheet)
    }
    
    func logoutConfirmed() {
        DispatchQueue.main.async {
            if let ctx = (NSApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                
                ctx.delete(self.user)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: Campaign.fetchRequest())
                do {
                    try ctx.execute(deleteRequest)
                }
                catch {}
                (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)
                
                let environment = [
                    "VIRTUAL_ENV": self.venvPath,
                    "ConsumerKey": self.user.consumerKey!,
                    "ConsumerSecret": self.user.consumerSecret!,
                    "AccessKey": self.user.accesskey!,
                    "AccessSecret": self.user.accessSecret!,
                    "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES"
                ]

                if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
                    let deleteProcess = Process()
                    deleteProcess.launchPath = "/usr/bin/env"
                    deleteProcess.environment = environment
                    deleteProcess.arguments = [self.venvPath + "/bin/python", main, "delete", "-a" ]
                    deleteProcess.launch()
                    deleteProcess.waitUntilExit()
                }

                self.noUserMode()
            }
        }

    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        confirmSheet.callback = logoutConfirmed
        confirmSheet.messageLabel.stringValue = "Do you really want to logout?"
        self.presentAsSheet(confirmSheet)
    }

    @IBAction func saveClicked(_ sender: Any) {
        let index = tableView.selectedRow
        campaigns[tableView.selectedRow].name = campaignNameTextField.stringValue
        campaigns[tableView.selectedRow].messageTemplate = messageTextTextField.stringValue
        (NSApplication.shared.delegate as? AppDelegate)?.saveAction(nil)

        refreshingStatusLabel.stringValue = "Saving..."
        refreshingStatusLabel.isHidden = false
        refreshingStatusLoader.isHidden = false
        refreshingStatusLoader.startAnimation(self)

        startButton.isEnabled = false
        pauseButton.isEnabled = false
        self.messageTextTextField.isEnabled = false
        self.campaignNameTextField.isEnabled = false
        self.strategyPopUpButton.isEnabled = false

        let id = String(index)
        let environment = [
         "VIRTUAL_ENV": venvPath
        ]

        if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
            let editProcess = Process()
            editProcess.launchPath = "/usr/bin/env"
            editProcess.environment = environment
            editProcess.arguments = [venvPath + "/bin/python", main, "edit", "--id", id, "--name", campaigns[tableView.selectedRow].name!, "--message", campaigns[tableView.selectedRow].messageTemplate!  ]
            editProcess.launch()
            DispatchQueue.global().async {
             editProcess.waitUntilExit()
             DispatchQueue.main.async {
                self.refreshingStatusLabel.isHidden = true
                self.refreshingStatusLoader.isHidden = true
                self.refreshingStatusLoader.stopAnimation(self)
                
                if let _ = sender as? Int {
                }
                else {
                    self.tableView.reloadData()
                    self.tableView?.selectRowIndexes([index], byExtendingSelection: false)
                }
                self.startButton.isEnabled = true
                self.messageTextTextField.isEnabled = true
                self.campaignNameTextField.isEnabled = true
                self.strategyPopUpButton.isEnabled = true
             }
            }
        }
    }
    
    @IBAction func startClicked(_ sender: Any) {
        startButton.isEnabled = false
        pauseButton.isEnabled = true
        saveClicked(-1)
        let index = tableView.selectedRow
        let id = String(index)
        let environment = [
            "VIRTUAL_ENV": venvPath,
            "ConsumerKey": user.consumerKey!,
            "ConsumerSecret": user.consumerSecret!,
            "AccessKey": user.accesskey!,
            "AccessSecret": user.accessSecret!,
            "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES"
        ]
        
        if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
            let startProcess = Process()
            startProcess.launchPath = "/usr/bin/env"
            startProcess.environment = environment
            startProcess.arguments = [venvPath + "/bin/python", main, "start", "--id", id ]
            startProcess.launch()
            startProcess.waitUntilExit()
        }
        refreshClicked(self)
    }

    @IBAction func pauseClicked(_ sender: Any) {
        startButton.isEnabled = true
        pauseButton.isEnabled = false

        let index = tableView.selectedRow
        let id = String(index)
        let environment = [
            "VIRTUAL_ENV": venvPath,
            "ConsumerKey": user.consumerKey!,
            "ConsumerSecret": user.consumerSecret!,
            "AccessKey": user.accesskey!,
            "AccessSecret": user.accessSecret!,
            "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES"
        ]
        
        if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
            let pauseProcess = Process()
            pauseProcess.launchPath = "/usr/bin/env"
            pauseProcess.environment = environment
            pauseProcess.arguments = [venvPath + "/bin/python", main, "stop", "--id", id ]
            pauseProcess.launch()
            pauseProcess.waitUntilExit()
        }
        
        refreshClicked(self)
    }

    @IBAction func refreshClicked(_ sender: Any) {
        refreshingStatusLabel.stringValue = "Refreshing status..."
        refreshingStatusLabel.isHidden = false
        refreshingStatusLoader.isHidden = false
        refreshingStatusLoader.startAnimation(self)
        
        startButton.isEnabled = false
        pauseButton.isEnabled = false
        saveButton.isEnabled = false
        refreshButton.isEnabled = false
        self.messageTextTextField.isEnabled = false
        self.campaignNameTextField.isEnabled = false
        self.strategyPopUpButton.isEnabled = false
        
        let index = tableView.selectedRow
        let id = String(index)
        let environment = [
            "VIRTUAL_ENV": venvPath
        ]
        
        if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
            let statusProcess = Process()
            statusProcess.launchPath = "/usr/bin/env"
            statusProcess.environment = environment
            let pipe = Pipe()
            statusProcess.standardOutput = pipe
            statusProcess.arguments = [venvPath + "/bin/python", main, "-f", "json", "status", "--id", id ]
            statusProcess.launch()
            DispatchQueue.global().async {
                statusProcess.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                do {
                    let status: StatusJSON = try JSONDecoder().decode(StatusJSON.self, from: data)
                    print(status.total)
                    print(status.sent)
                    print(status.started)
                    DispatchQueue.main.async {
                        self.statusResultLabel.stringValue = String(status.sent) + " / " + String(status.total)
                        self.refreshingStatusLabel.isHidden = true
                        self.refreshingStatusLoader.isHidden = true
                        self.refreshingStatusLoader.stopAnimation(self)
                        self.refreshButton.isEnabled = true

                        if (status.started) {
                            self.pauseButton.isEnabled = true
                            self.saveButton.isEnabled = false
                            self.messageTextTextField.isEnabled = false
                            self.campaignNameTextField.isEnabled = false
                            self.strategyPopUpButton.isEnabled = false
                        }
                        else {
                            self.startButton.isEnabled = true
                            self.saveButton.isEnabled = true
                            self.messageTextTextField.isEnabled = true
                            self.campaignNameTextField.isEnabled = true
                            self.strategyPopUpButton.isEnabled = true
                        }
                    }
                }
                catch {
                    print("deserialization failed")
                }
            }
        }
    }

    func resetClickConfirmed() {
        let index = tableView.selectedRow
        let id = String(index)
        let environment = [
            "VIRTUAL_ENV": venvPath,
            "ConsumerKey": user.consumerKey!,
            "ConsumerSecret": user.consumerSecret!,
            "AccessKey": user.accesskey!,
            "AccessSecret": user.accessSecret!,
            "OBJC_DISABLE_INITIALIZE_FORK_SAFETY": "YES"
        ]
        
        if let main = Bundle.main.path(forResource: "twitter-campaign-cli/main.py", ofType: "") {
            let resetProcess = Process()
            resetProcess.launchPath = "/usr/bin/env"
            resetProcess.environment = environment
            let pipe = Pipe()
            resetProcess.standardOutput = pipe
            resetProcess.arguments = [venvPath + "/bin/python", main, "-f", "json", "reset", "--id", id ]
            resetProcess.launch()
            resetProcess.waitUntilExit()
        }
        DispatchQueue.main.async {
            self.refreshClicked(self)
        }
    }
    
    @IBAction func resetClicked(_ sender: Any) {
        confirmSheet.callback = resetClickConfirmed
        confirmSheet.messageLabel.stringValue = "Do you really want to reset this campaign?"
        self.presentAsSheet(confirmSheet)
    }
}

