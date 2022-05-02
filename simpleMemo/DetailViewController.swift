//
//  DetailViewController.swift
//  simpleMemo
//
//  Created by hhj on 2022/04/02.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var memoTableView: UITableView!
    
    var memo: Memo? // 이전 화면에서 전달한 새로운 메모를 할당할 변수
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    @IBAction func deleteMemo(_ sender: Any) {
        let alert = UIAlertController(title: "삭제 확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        // 두번째 style 파라미터로 .destructive 를 전달하면 텍스트가 빨간색으로 표시됨
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] (action) in
            DataManager.shared.deleteMemo(self?.memo) // 메모 삭제 실행
            // 네비게이션 컨트롤러에 접근해서 현재 화면을 pop(식제)
            self?.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 작성한 alert을 컨트롤러에 추가
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 경고창을 화면에 표시
        present(alert, animated: true, completion: nil)
    }
    
    // 메모 수정에서 접근 한 경우 segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.children.first as? ComposeViewController {
            vc.editTarget = memo
        }
    }
    
    var token: NSObjectProtocol?
    
    // 옵저버 해제
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 옵저버 추가
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.memoDidChange, object: nil, queue: OperationQueue.main, using: {[weak self] (noti) in self?.memoTableView.reloadData()})
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

// 데이터 소스 연결을 위한 익스텐션
extension DetailViewController: UITableViewDataSource {
    // 프로토콜의 필수 메소드
    // 테이블 뷰가 표시할 셀의 숫자 prototype cells 개수만큼 (텍스트, 날짜 총 2)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // 프로토콜의 필수 메소드
    // 테이블 뷰가 어떤 셀을 표시할지 지정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        // 첫번째 셀에는 메모 텍스트를 표시 (셀의 identifier 지정)
        case 0:
            // 첫번째 셀을 저장해서 cell 에 저장
            let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
            cell.textLabel?.text = memo?.content
            
            return cell
            
        // 두번째 셀에는 날짜를 표시
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
            cell.textLabel?.text = formatter.string(for: memo?.insertDate)
            
            return cell
            
        // 표시할 셀을 지정하지 않았을땐 크래시
        default:
            fatalError()
        }
    }
    
    
}
