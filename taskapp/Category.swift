


import RealmSwift


class Category: Object {
//    管理用ID プライマリ-キー
    @objc dynamic var id = 0

    //カテゴリ
    @objc dynamic var title: String = ""

    //IDをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }

}

//import Foundation
//
//class TestCategory {
//    var title: [String] = ["カテゴリ１","カテゴリ２"]
//}
