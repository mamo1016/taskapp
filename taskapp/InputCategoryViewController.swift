//
//  InputCategoryViewController.swift
//  taskapp
//
//  Created by 上田　護 on 2018/07/11.
//  Copyright © 2018年 mamoru.ueda. All rights reserved.
//

import UIKit
import RealmSwift


class InputCategoryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
//    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    var category: Category!
    let realm = try! Realm()
    var categoryArray = try! Realm() .objects(Category.self).sorted(byKeyPath: "title", ascending: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // プロトコルの設定
        pickerView.delegate = self
        pickerView.dataSource = self
        // はじめに表示する項目を指定
        pickerView.selectRow(1, inComponent: 0, animated: true)

    }
    
    // UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 表示する列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // アイテム表示個数を返す
        return categoryArray.count
    }
    
    // UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        return categoryArray[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
//        print(dataList[row])
//        categoryLabel.text = categoryArray[row].title
    }
    
    @IBAction func addCategory(){
        try! realm.write {
            //テキストフィールドがからの時はカテゴリ追加しない
            if textField.text != ""{
                self.category.title = self.textField.text!
                self.realm.add(self.category, update: true)
            }
        }
    }
    // 追加する
//    override func viewWillDisappear(_ animated: Bool) {
//        try! realm.write {
//            //テキストフィールドがからの時はカテゴリ追加しない
//            if textField.text != ""{
//                self.category.title = self.textField.text!
//                self.realm.add(self.category, update: true)
//            }
//        }
//        super.viewWillDisappear(animated)
//    }
}
