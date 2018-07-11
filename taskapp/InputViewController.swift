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

class InputViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    var task: Task!
    let realm = try! Realm()
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景タップでdismissKeyboardメソッド呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        //表示
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category

        titleTextField.returnKeyType = .done
        categoryTextField.returnKeyType = .done
        categoryTextField.placeholder = "カテゴリを入力"

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
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
        print("キー入力終了")
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

        if task.category == "" {
            content.body = "(カテゴリなし)"
        } else {
            content.body = task.category
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
}
