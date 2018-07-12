//
//  ViewController.swift
//  taskapp
//
//  Created by 上田　護 on 2018/07/06.
//  Copyright © 2018年 mamoru.ueda. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categorySearch: UISearchBar!

    var searchController = UISearchController()
    var i: Int = 0
    //Realmインスタンス取得
    let realm = try! Realm()

    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm() .objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    var searchResult: Results<Task>!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //テーブルビューのヘッダーにサーチバーを設定する。
        tableView.tableHeaderView = searchController.searchBar
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: UITableViewDataSorceのプロトコルメソッド
    //データの数を返すメソッド(セル数)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
    }
    
//  各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
     
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM--dd:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
//        print(task)
//        i += 1
        return cell
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

//    セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
//  deleteボタンが押された時のメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            //削除されたタスクを取得
            let task = self.taskArray[indexPath.row]
            //ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知をログ出力
            center.getPendingNotificationRequests {
                (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-----------------------")
                    print(request)
                    print("-----------------------/")
                }
            }
        }
    }
    
    //画面遷移する前に呼ばれるメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = Date()
            let allTasks = realm.objects(Task.self)

            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    
    //検索文字列変更時の呼び出しメソッド
    func updateSearchResults(for searchController: UISearchController) {
        
        print(searchController.searchBar.text!.lowercased())
        if searchController.searchBar.text!.lowercased() == "" {
            taskArray = try! Realm() .objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        }else{
            taskArray = realm.objects(Task.self).filter("category = '\(searchController.searchBar.text!.lowercased())' OR title = '\(searchController.searchBar.text!.lowercased())'")
        }

        //テーブルビューを再読み込みする。
        tableView.reloadData()
    }
}

