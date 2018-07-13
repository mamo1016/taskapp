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

    
    var task: Task!
    var category: Category!
    let realm = try! Realm()
    var categoryArray = try! Realm() .objects(Task.self).sorted(byKeyPath: "title", ascending: false)
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
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        for i in 0..<categoryArray.count{
//            if task.category == categoryArray[i].title && task.category != ""{
//                categoryPicker.selectRow(i, inComponent: 0, animated: true)
//                print(task.category)
//            }
            if task.category2?.title == categoryArray[i].title && task.category != ""{
                categoryPicker.selectRow(i, inComponent: 0, animated: true)
            }
        }
        print(task.category2)
//        var test =
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        categoryArray = try! Realm() .objects(Task.self).sorted(byKeyPath: "category", ascending: false)
        // はじめに表示する項目を指定
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        for i in 0..<categoryArray.count{
            if task.category2?.title == categoryArray[i].title && task.category2?.title != ""{
                categoryPicker.selectRow(i, inComponent: 0, animated: true)
//                print(task.category2?.title)
            }
        }
        
//        print("willapear")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            if changeCategory {
                self.task.category2?.title = self.categoryTitle!
            }
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismissKeyboard(){
//        print("キー入力終了")
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

        if task.category2?.title == "" {
            content.body = "(カテゴリなし)"
        } else {
            content.body = (task.category2?.title)!
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
//            print(error ?? "ローカル通知登録OK") //??演算子　左がnilでなければ左を表示，左がnilなら右を表示
        }
        
        //未通知のローカル通知をログ出力
        center.getPendingNotificationRequests{ (requests: [UNNotificationRequest]) in
            for request in requests {
//                print("/-----------")
//                print(request)
//                print("-----------/")
                
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
        // 選択時の処理
        categoryTitle = categoryArray[row].title
        changeCategory = true
    }
    
    
    // segue で画面遷移するに呼ばれる
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
