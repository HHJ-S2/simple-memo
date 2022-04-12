//
//  ComposeViewController.swift
//  simpleMemo
//
//  Created by hhj on 2022/04/02.
//

import UIKit

class ComposeViewController: UIViewController {
    
    var editTarget: Memo? // 수정 할 메모

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
            memo.count > 0 else {
                // 글자수가 0개 이하일 경우 alert
                alert(message: "메모를 입력하세요")
                return
            }
        
//        Model 의 Memo 클래스에 접근
//        let newMemo = Memo(content: memo)
//        Memo.dummyMemoList.append(newMemo)
        
        // editTarget에 값이 있으면 수정된 텍스트를 저장
        if let target = editTarget {
            target.content = memo
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else {
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // ViewController 가 생성된 후 호출, 1번만 실행되는 초기화 코드를 작성
    override func viewDidLoad() {
        super.viewDidLoad()

        // editTarget에 값이 있으면 타이틀과 텍스트를 수정
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
        } else {
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
