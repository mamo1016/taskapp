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

class InputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    var task: Task!
    var category: Category!
    let realm = try! Realm()
    var categoryArray = try! Realm() .objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    var categoryTitle: String!
    var changeCategory: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景タップでdismissKeyboardメソッド呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        //表示
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        titleTextField.returnKeyType = .done
        // プロトコルの設定
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        // はじめに表示する項目を指定
        if(task.category?.id != nil){
            categoryPicker.selectRow((task.category?.id)!, inComponent: 0, animated: true)
        }
//        categoryPicker.selectRow((task.category?.id)!, inComponent: 0, animated: true)
        categoryLabel.text = task.category?.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        categoryPicker.reloadAllComponents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//データベース書き込み
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
//            if changeCategory {
//                self.task.category?.title = self.categoryLabel.text!
//                self.category.title = "aaaaaaaaaaa"
//                self.category.title = self.titleTextField.text!
//                print(self.task.category?.title)
//            }
//            self.realm.add(self.category, update: true)
            self.realm.add(self.task, update: true)
//            print("--------\(String(describing: task.category?.title))")
            print(task)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    //通知の設定
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合はメッセージ無しで音だけ通知になる「xxなし」を表示する
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }

        if task.category?.title == nil {
            content.body = "(カテゴリなし)"
        } else {
            content.body = (task.category?.title)!
        }
        content.sound = UNNotificationSound.default()
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        //identifier, content, triggerからのローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
            print(error ?? "ローカル通知登録OK") //??演算子　左がnilでなければ左を表示，左がnilなら右を表示
        }
        
        //未通知のローカル通知をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/-----------")
                print(request)
                print("-----------/")
            }
        }
    }
    
    func textFieldShouldReturn(titleTextField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
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
        if categoryArray.count != 0{
            // 選択時の処理
            categoryTitle = categoryArray[row].title
            changeCategory = true
            categoryLabel.text = categoryArray[row].title
            
            try! realm.write {
                self.task.category = self.categoryArray[row]
            }
        }
    }
    
    
    // segue で画面遷移する前に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputCatgoryViewController:InputCategoryViewController = segue.destination as! InputCategoryViewController
        
        let category = Category()
        
        let allCategorys = realm.objects(Category.self)
        if allCategorys.count != 0 {
            category.id = allCategorys.max(ofProperty: "id")! + 1
        }
        inputCatgoryViewController.category = category
    }
    
    
    
}
