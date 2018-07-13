//
//  InputViewController.swift
//  taskapp
//
//  Created by 上田　護 on 2018/07/06.
//  Copyright © 2018年 mamoru.ueda. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class testViewController: UIViewController {
    
    var task: Task!
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
//            self.task.category = "test"
//            self.realm.add(self.task, update: true)
        }
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
