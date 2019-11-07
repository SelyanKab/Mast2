//
//  HashtagViewController.swift
//  Mast
//
//  Created by Shihab Mehboob on 07/11/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class HashtagViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    public var isSplitOrSlideOver: Bool {
        let windows = UIApplication.shared.windows
        for x in windows {
            if let z = self.view.window {
                if x == z {
                    if x.frame.width == x.screen.bounds.width || x.frame.width == x.screen.bounds.height {
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
        return false
    }
    var tableView = UITableView()
    var loginBG = UIView()
    var refreshControl = UIRefreshControl()
    let top1 = UIButton()
    let btn2 = UIButton(type: .custom)
    var userId = GlobalStruct.currentUser.id
    var statusesHashtags: [Status] = []
    var theHashtagID: String = ""
    var theHashtag: String = ""
    let btn1 = UIButton(type: .custom)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Table
        let tableHeight = (self.navigationController?.navigationBar.bounds.height ?? 0)
        self.tableView.frame = CGRect(x: 0, y: tableHeight, width: self.view.bounds.width, height: (self.view.bounds.height) - tableHeight)
    }
    
    @objc func updatePosted() {
        print("toot toot")
    }
    
    @objc func scrollTop1() {
        if self.tableView.alpha == 1 {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        GlobalStruct.currentTab = 999
    }
    
    @objc func refreshTable1() {
        self.tableView.reloadData()
    }
    
    @objc func notifChangeTint() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "baseWhite")
        self.title = "#\(self.theHashtag)"
//        self.removeTabbarItemsText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePosted), name: NSNotification.Name(rawValue: "updatePosted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.scrollTop1), name: NSNotification.Name(rawValue: "scrollTop1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable1), name: NSNotification.Name(rawValue: "refreshTable1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notifChangeTint), name: NSNotification.Name(rawValue: "notifChangeTint"), object: nil)

        // Add button
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        btn1.setImage(UIImage(systemName: "plus", withConfiguration: symbolConfig)?.withTintColor(UIColor(named: "baseBlack")!.withAlphaComponent(1), renderingMode: .alwaysOriginal), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.addTapped), for: .touchUpInside)
        btn1.accessibilityLabel = "Create".localized
        let addButton = UIBarButtonItem(customView: btn1)
        if UIDevice.current.userInterfaceIdiom == .pad && self.isSplitOrSlideOver == false {} else {
            self.navigationItem.setRightBarButton(addButton, animated: true)
        }
        
        // Table
        self.tableView.register(TootCell.self, forCellReuseIdentifier: "TootCell")
        self.tableView.register(TootImageCell.self, forCellReuseIdentifier: "TootImageCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = UIColor(named: "baseBlack")?.withAlphaComponent(0.24)
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.statusesHashtags = []
        self.initialFetches()
        
        // Top buttons
        let tab0 = (self.navigationController?.navigationBar.bounds.height ?? 0) + 10
        let startHeight = (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + tab0
        let symbolConfig2 = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        
        self.top1.frame = CGRect(x: Int(self.view.bounds.width) - 48, y: Int(startHeight + 6), width: 38, height: 38)
        self.top1.setImage(UIImage(systemName: "chevron.up.circle.fill", withConfiguration: symbolConfig2)?.withTintColor(GlobalStruct.baseTint, renderingMode: .alwaysOriginal), for: .normal)
        self.top1.backgroundColor = UIColor(named: "baseWhite")
        self.top1.layer.cornerRadius = 19
        self.top1.alpha = 0
        self.top1.addTarget(self, action: #selector(self.didTouchTop1), for: .touchUpInside)
        self.top1.accessibilityLabel = "Top".localized
        self.view.addSubview(self.top1)
    }
    
    @objc func didTouchTop1() {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func initialFetches() {
        let request = Timelines.tag(self.theHashtag, local: false)
        GlobalStruct.client.run(request) { (statuses) in
            if let stat = (statuses.value) {
                DispatchQueue.main.async {
                    self.statusesHashtags = stat
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut, animations: {
            self.top1.alpha = 0
            self.top1.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        }) { (completed: Bool) in
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statusesHashtags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.statusesHashtags[indexPath.row].mediaAttachments.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TootCell", for: indexPath) as! TootCell
            if self.statusesHashtags.isEmpty {} else {
                cell.configure(self.statusesHashtags[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
            }

            cell.content.handleHashtagTap { (string) in
                let vc = HashtagViewController()
                vc.theHashtag = string
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.content.handleURLTap { (string) in
                GlobalStruct.tappedURL = string
                ViewController().openLink()
            }
            
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TootImageCell", for: indexPath) as! TootImageCell
            if self.statusesHashtags.isEmpty {} else {
                cell.configure(self.statusesHashtags[indexPath.row])
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewProfile(_:)))
                cell.profile.tag = indexPath.row
                cell.profile.addGestureRecognizer(tap)
            }

            cell.content.handleHashtagTap { (string) in
                let vc = HashtagViewController()
                vc.theHashtag = string
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.content.handleURLTap { (string) in
                GlobalStruct.tappedURL = string
                ViewController().openLink()
            }
            
            cell.backgroundColor = UIColor(named: "baseWhite")
            let bgColorView = UIView()
            bgColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }
    
    @objc func viewProfile(_ gesture: UIGestureRecognizer) {
        let vc = FifthViewController()
        vc.isYou = false
        vc.pickedCurrentUser = self.statusesHashtags[gesture.view!.tag].account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.pickedStatusesHome = [self.statusesHashtags[indexPath.row]]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.highlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TootCell {
            cell.unhighlightCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            guard let indexPath = configuration.identifier as? IndexPath else { return }
            let vc = DetailViewController()
            vc.pickedStatusesHome = [self.statusesHashtags[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: {
            let vc = DetailViewController()
            vc.fromContextMenu = true
            vc.pickedStatusesHome = [self.statusesHashtags[indexPath.row]]
            return vc
        }, actionProvider: { suggestedActions in
            return self.makeContextMenu([self.statusesHashtags[indexPath.row]], indexPath: indexPath)
        })
    }
    
    func makeContextMenu(_ status: [Status], indexPath: IndexPath) -> UIMenu {
        let repl = UIAction(title: "Reply".localized, image: UIImage(systemName: "arrowshape.turn.up.left"), identifier: nil) { action in
            let vc = TootViewController()
            vc.replyStatus = status
            self.show(UINavigationController(rootViewController: vc), sender: self)
        }
        var boos = UIAction(title: "Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
            self.toggleBoostOn(status)
        }
        if status.first?.reblogged ?? false {
            boos = UIAction(title: "Remove Boost".localized, image: UIImage(systemName: "arrow.2.circlepath"), identifier: nil) { action in
                self.toggleBoostOff(status)
            }
        }
        var like = UIAction(title: "Like".localized, image: UIImage(systemName: "heart"), identifier: nil) { action in
            self.toggleLikeOn(status)
        }
        if status.first?.favourited ?? false {
            like = UIAction(title: "Remove Like".localized, image: UIImage(systemName: "heart.slash"), identifier: nil) { action in
                self.toggleLikeOff(status)
            }
        }
        let shar = UIAction(title: "Share".localized, image: UIImage(systemName: "square.and.arrow.up"), identifier: nil) { action in
            self.shareThis(status)
        }
        let tran = UIAction(title: "Translate".localized, image: UIImage(systemName: "globe"), identifier: nil) { action in
            self.translateThis(status)
        }
        let mute = UIAction(title: "Mute".localized, image: UIImage(systemName: "eye.slash"), identifier: nil) { action in
            self.muteThis(status)
        }
        let bloc = UIAction(title: "Block".localized, image: UIImage(systemName: "hand.raised"), identifier: nil) { action in
            self.blockThis(status)
        }
        let dupl = UIAction(title: "Duplicate".localized, image: UIImage(systemName: "doc.on.doc"), identifier: nil) { action in
            self.duplicateThis(status)
        }
        let repo = UIAction(title: "Report".localized, image: UIImage(systemName: "flag"), identifier: nil) { action in
            self.reportThis(status)
        }
        let delete = UIAction(title: "Delete".localized, image: UIImage(systemName: "trash"), identifier: nil) { action in
            
        }
        delete.attributes = .destructive
        let more = UIMenu(__title: "More".localized, image: UIImage(systemName: "ellipsis.circle"), identifier: nil, options: [], children: [tran, mute, bloc, dupl, repo])
        
        return UIMenu(__title: "", image: nil, identifier: nil, children: [repl, boos, like, shar, more])
    }
    
    func toggleBoostOn(_ stat: [Status]) {
        let request = Statuses.reblog(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleBoostOff(_ stat: [Status]) {
        let request = Statuses.unreblog(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleLikeOn(_ stat: [Status]) {
        let request = Statuses.favourite(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func toggleLikeOff(_ stat: [Status]) {
        let request = Statuses.unfavourite(id: stat.first?.id ?? "")
        GlobalStruct.client.run(request) { (statuses) in
            
        }
    }
    
    func shareThis(_ stat: [Status]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: " Share Content".localized, style: .default , handler:{ (UIAlertAction) in
            let textToShare = [stat.first?.content.stripHTML() ?? ""]
            let activityViewController = UIActivityViewController(activityItems: textToShare,  applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = cell.button4
                activityViewController.popoverPresentationController?.sourceRect = cell.button4.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op1.setValue(UIImage(systemName: "doc.append")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "Share Link".localized, style: .default , handler:{ (UIAlertAction) in
            let textToShare = [stat.first?.url?.absoluteString ?? ""]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                activityViewController.popoverPresentationController?.sourceView = cell.button4
                activityViewController.popoverPresentationController?.sourceRect = cell.button4.bounds
            }
            self.present(activityViewController, animated: true, completion: nil)
        })
        op2.setValue(UIImage(systemName: "link")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func translateThis(_ stat: [Status]) {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        let bodyText = stat.first?.content.stripHTML() ?? ""
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharset = NSCharacterSet(charactersIn: unreservedChars)
        var trans = bodyText.addingPercentEncoding(withAllowedCharacters: unreservedCharset as CharacterSet)
        trans = trans!.replacingOccurrences(of: "\n\n", with: "%20")
        let langStr = Locale.current.languageCode
        let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=\(langStr ?? "en")&dt=t&q=\(trans!)&ie=UTF-8&oe=UTF-8"
        guard let requestUrl = URL(string:urlString) else {
            return
        }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) as! [Any]
                    var translatedText = ""
                    for i in (json[0] as! [Any]) {
                        translatedText = translatedText + ((i as! [Any])[0] as? String ?? "")
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: nil, message: translatedText as? String ?? "Could not translate tweet", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
                            
                        }))
                        if let presenter = alert.popoverPresentationController {
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                                presenter.sourceView = self.view
                                presenter.sourceRect = self.view.bounds
                            }
                        }
                        self.present(alert, animated: true, completion: nil)
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func muteThis(_ stat: [Status]) {
        
    }
    
    func blockThis(_ stat: [Status]) {
        
    }
    
    func duplicateThis(_ stat: [Status]) {
        
    }
    
    func reportThis(_ stat: [Status]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let op1 = UIAlertAction(title: "Harassment".localized, style: .default , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "Harassment")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op1.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op1.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op1)
        let op2 = UIAlertAction(title: "No Content Warning".localized, style: .default , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "No Content Warning")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op2.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op2.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op2)
        let op3 = UIAlertAction(title: "Spam".localized, style: .default , handler:{ (UIAlertAction) in
            let request = Reports.report(accountID: stat.first?.account.id ?? "", statusIDs: [stat.first?.id ?? ""], reason: "Spam")
            GlobalStruct.client.run(request) { (statuses) in
                
            }
        })
        op3.setValue(UIImage(systemName: "flag")!, forKey: "image")
        op3.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        alert.addAction(op3)
        alert.addAction(UIAlertAction(title: "Dismiss".localized, style: .cancel , handler:{ (UIAlertAction) in
            
        }))
        if let presenter = alert.popoverPresentationController {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? DetailActionsCell {
                presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func addTapped() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "addTapped"), object: self)
    }
    
    func removeTabbarItemsText() {
        if let items = self.tabBarController?.tabBar.items {
            for item in items {
                item.title = ""
            }
        }
    }
}

