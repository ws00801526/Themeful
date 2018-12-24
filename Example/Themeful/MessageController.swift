//  MessageController.swift
//  Themeful
//
//  Created by  XMFraker on 2018/12/24
//  Copyright © XMFraker All rights reserved. (https://github.com/ws00801526)
//  @class      MessageController
//  @version    <#class version#>
//  @abstract   <#class description#>

import UIKit
import Themeful

class MessageController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var backgroundView: UIImageView? { return tableView.backgroundView as? UIImageView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) { tableView.contentInsetAdjustmentBehavior = .never }
        tableView.backgroundView = UIImageView(frame: tableView.bounds)
        
//        "message": {
//            "background" : "qvip_conversation_bg_animate",
//            "headBackground" : "header_bg_ios7",
//            "headShadow" : "header_bg_shadow",
//            "searchBarchground" : "searchbar_bg",
//            "searchIcon" : "searchbar_icon_search",
//            "searchInput" : "searchbar_inputbox",
//            "segmentedLeft" : "header_leftbtn_nor"
//            "segmentedLeftPress" : "header_leftbtn_press"
//            "segmentedMiddle" : "header_midtab_nor",
//            "segmentedMiddlePress" : "header_midtab_press",
//            "segmentedRight" : "header_righttab_nor"
//            "segmentedRightPress" : "header_righttab_press"
//        },
        
        searchBar.placeholder = "搜索"
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 44)
        let _ = button.theme.setImage("message.headMenu", for: .normal).setImage("message.headMenuPress", for: .highlighted)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        let _ = backgroundView?.theme.setImage("message.background")
        
        let _ = navigationController?.navigationBar.theme
                .setBackgroundImage("message.headBackground")
                .setShadowImage("message.headShadow")

        let _ = searchBar.theme
                .setBackgroundImage("message.searchBarchground")
                .setImage("message.searchIcon", for: .search, state: .normal)
                .setSearchFieldBackgroundImage("message.searchInput", for: .normal)
        
//        let _ = segmentedControl.theme
//                .setImage("message.segmentedLeft", forSegmentAt: 0)
//                .setImage("message.segmentedRight", forSegmentAt: 1)
    }
    
}

extension MessageController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
}
