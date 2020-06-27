//
//  FollowerListViewController.swift
//  Twitter Campaigns
//
//  Created by Kanav Gupta on 27/06/20.
//  Copyright © 2020 Kanav Gupta. All rights reserved.
//

import Cocoa

struct Follower: Decodable {
    let name: String
    let handle: String
    var sent: Bool
    let count: Int64
}

class FollowerListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var followers: [Follower] =  []
    var mainViewController: ViewController?
    @IBOutlet weak var loadingLabel: NSTextField!
    @IBOutlet weak var loadingProgress: NSProgressIndicator!
    var empty = true
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var forceSendButton: NSButton!
    
    @IBAction func onCloseClick(_ sender: Any) {
        mainViewController?.dismiss(self)
    }
    
    // MARK: - TableView Code
    func numberOfRows(in tableView: NSTableView) -> Int {
        return empty ? 0 : followers.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var iden = ""
        var val = ""
        if tableColumn == tableView.tableColumns[0] {
            iden = "c1"
            val = String(row + 1)
        }
        else if tableColumn == tableView.tableColumns[1] {
            iden = "c2"
            val = followers[row].name + " (@\(followers[row].handle))"
        }
        else if tableColumn == tableView.tableColumns[2] {
            iden = "c3"
            val = String(followers[row].count)
        }
        else if tableColumn == tableView.tableColumns[3] {
            iden = "c4"
            if (followers[row].sent) {
                val = "✅"
            }
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: iden), owner: self) as? NSTableCellView {
            
            cell.textField?.stringValue = val
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow == -1 {
            forceSendButton.isEnabled = false
        } else {
            forceSendButton.isEnabled = true
        }
    }
    
    @IBAction func onForceSendClick(_ sender: Any) {
        let follower = followers[tableView.selectedRow]
        mainViewController?.sendDM(handle: follower.handle) {
            self.followers[self.tableView.selectedRow].sent = true
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [3])
        }
    }
}
