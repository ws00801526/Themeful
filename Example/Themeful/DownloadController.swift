//  DownloadController.swift
//  Themeful
//
//  Created by  XMFraker on 2018/12/18
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      DownloadController
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit
import Themeful
import SwiftyJSON

struct ThemeModel : ThemefulDownloadProtocol {
    var remoteURL: URL?
    var name: String = ""
    var config: NSDictionary?
    
    var canClear: Bool { return remoteURL != nil }
    
    func theme() -> Theme? {
        if remoteURL == nil { return Theme(name, path: .mainBundle) }
        return Theme.downloadedTheme(of: name)
    }
    
    init(name: String, remoteURL: URL? = nil, config: NSDictionary? = nil) {
        self.name = name
        self.remoteURL = remoteURL
        self.config = config
    }
}

fileprivate let DOWNLOAD_URL = "https://image.zuifuli.com/14/20181220/b0ec6e8376f06ae94c0d851f13d4a620.zip"
fileprivate let JD_DOWNLOAD_URL = "https://image.zuifuli.com/14/20181220/8cacb2f6a4d7bae62027257020b9c9a7.zip"
fileprivate let HOTS_DOWNLOAD_URL = "https://image.zuifuli.com/14/20181220/5c70d6d37b97ccfbb51ce0ad58e05629.zip"

fileprivate let QQ_DOWNLOAD_URL_PREFIX = "https://gxh.vip.qq.com/xydata"

class ThemeManageCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
}


class DownloadController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var config: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let URL = Bundle.main.url(forResource: "Config", withExtension: "json") {
            if let data = try? Data(contentsOf: URL) {
                if let config = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    self.config = config
                }
            }
        }
    }
    
    lazy var themeModels: [ThemeModel] = { return mainBundles + sandboxs + qqinfos }()

    var mainBundles: [ThemeModel] { return [ThemeModel(name: "Valentine.strings"), ThemeModel(name: "Chinese.strings")] }
    
    var sandboxs: [ThemeModel] {
        return [
                ("JD", JD_DOWNLOAD_URL),
                ("Hots", HOTS_DOWNLOAD_URL)
            ] .map { ThemeModel(name: $0.0, remoteURL: URL(string: $0.1), config: nil) }
    }
    
    lazy var qqinfos: [ThemeModel] = {

        var infos: [ThemeModel] = []
        ["1.json","2.json","3.json"].forEach({
            if let url = Bundle.main.url(forResource: $0, withExtension: nil) {
                if let data = try? Data(contentsOf: url) {
                    if let JSON = try? JSON(data: data) {
                        let items = JSON["data"]["itemList"].arrayValue
                        let newInfos = items.map({ [unowned self] item -> ThemeModel in
                            let name = item["name"].stringValue
                            let URLString = "\(QQ_DOWNLOAD_URL_PREFIX)\(item["zip"].stringValue)"
                            let remoteURL = URL(string: URLString)
                            return ThemeModel(name: name, remoteURL: remoteURL, config: self.config)
                        })
                        infos.append(contentsOf: newInfos)
                    }
                }
            }
        })
        return infos
    }()
    
//    var qqinfos: [ThemeModel] {
//        return [
//                ("葬爱", "https://gxh.vip.qq.com/xydata/theme/item/2558/2558_i_4_7_i_2.zip")
//            ].map { ThemeModel(name: $0.0, remoteURL: URL(string: $0.1), config: self.config) }
//    }
}

extension DownloadController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return themeModels.count }
//        else if section == 1 { return qqinfos.count }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeManageCell", for: indexPath) as! ThemeManageCell
        cell.downloadButton.tag = indexPath.row
        cell.downloadButton.addTarget(self, action: #selector(handleDownAction(_:)), for: .touchUpInside)
        cell.clearButton.tag = indexPath.row
        cell.clearButton.addTarget(self, action: #selector(handleClearAction(_:)), for: .touchUpInside)
        cell.progressView.progress = 0.0
        let themeModel = themeModels[indexPath.row]
        cell.statusLabel.text = themeModel.name
        if let _ = themeModel.theme() {
            cell.clearButton.isHidden = false
            cell.downloadButton.setTitle("使用", for: .normal)
        } else {
            cell.clearButton.isHidden = themeModel.canClear
            cell.downloadButton.setTitle("下载", for: .normal)
        }
        return cell
    }
}

extension DownloadController {
    
    @IBAction func handleDownAction(_ button: UIButton) -> Void {
        guard button.tag < themeModels.count else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? ThemeManageCell else { return }
        let themeInfo = themeModels[button.tag]
        if let theme = themeModels[button.tag].theme() {
            let _ = ThemeManager.setTheme(theme: theme)
        } else {
            let _ = ThemeDownloadManager.shared.downloadTheme(with: themeInfo, downloadProgress: { (_, total, expected) in
                cell.statusLabel.text = "\(themeInfo.name) Start Downloading"
                cell.progressView.progress = (Float(total) / Float(expected))
            }, unzipProgress: { (loaded, total) in
                cell.statusLabel.text = "\(themeInfo.name) Start Unziping"
                cell.progressView.progress = (Float(loaded) / Float(total))
            }) { (theme, error) in
                if let error = error {
                    cell.statusLabel.text = "\(themeInfo.name) failed : \(error.localizedDescription)"
                } else {
                    cell.statusLabel.text = "\(themeInfo.name) finished"
                    cell.downloadButton.setTitle("使用", for: .normal)
                    cell.clearButton.isHidden = false
                }
            }
        }
    }

    @IBAction func handleClearAction(_ button: UIButton) -> Void {

        guard button.tag < themeModels.count else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? ThemeManageCell else { return }
        let themeInfo = themeModels[button.tag]
        let succ = ThemeDownloadManager.shared.clearThemeCache(with: themeInfo.name)
        if succ {
            cell.clearButton.isHidden = true
            cell.downloadButton.setTitle("下载", for: .normal)
        }
    }
}
