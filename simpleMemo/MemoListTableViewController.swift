//
//  MemoListTableViewController.swift
//  simpleMemo
//
//  Created by hhj on 2022/03/29.
//

import UIKit

class MemoListTableViewController: UITableViewController {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        새로운 메모를 작성한 뒤 데이터 업데이트 (뷰가 page sheet 일 경우 작동하지않음)
//        tableView.reloadData()
//        print(#function)
    }
    
    var token: NSObjectProtocol?
    
    // Notification 의 토큰 관리 (메모리를 위한?)
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // segue가 연결된 화면을 생성하고 화면을 전환하기 직전에 호출
    // 첫번째 파라미터로 현재 실행중인 segue를 통해 목록화면과 보기화면에 접근
    // 두번째 파라미터를 활용해 몇번째 셀인지 체크
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = Memo.dummyMemoList[indexPath.row]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.tableView.reloadData()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Memo.dummyMemoList.count
    }

    // 개별 셀을 화면에 표시할 때마다 반복적으로 호출
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // indexPath로 셀 위치를 불러옴
        
        // 사용할 셀 디자인 지정
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // 표시할 데이터를 indexPath.row로 가져오고 타이틀과 서브타이틀을 지정함
        let target = Memo.dummyMemoList[indexPath.row]
        
        cell.textLabel?.text = target.content
        // 상단의 DateFormatter 를 사용하여 지정한 날짜 포멧 문자열로 변환
        cell.detailTextLabel?.text = formatter.string(from: target.insertDate)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
