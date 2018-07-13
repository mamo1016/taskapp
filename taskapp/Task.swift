//
//  Task.swift
//  taskapp
//
//  Created by 上田　護 on 2018/07/08.
//  Copyright © 2018年 mamoru.ueda. All rights reserved.
//

//import Foundation
import RealmSwift

class Task: Object {
    //管理用ID プライマリ-キー
    @objc dynamic var id = 0
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //カテゴリ
//    @objc dynamic var category = ""
    @objc dynamic var category: Category?

    //IDをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}

//
