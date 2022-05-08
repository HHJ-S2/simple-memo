//
//  ComposeViewController.swift
//  simpleMemo
//
//  Created by hhj on 2022/04/02.
//

import UIKit

class ComposeViewController: UIViewController {

    var editTarget: Memo? // 수정 할 메모
    var originalMemoContent: String? // 편집 하기 전의 메모

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

    // 옵저버 해제를 위해 사용되는 토큰
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?

    // 화면이 제거될때 옵저버가 제거됨
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    // ViewController 가 생성된 후 호출, 1번만 실행되는 초기화 코드를 작성
    override func viewDidLoad() {
        super.viewDidLoad()

        // editTarget에 값이 있으면 타이틀과 텍스트를 수정
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
        } else {
            navigationItem.title = "새 메모"
            memoTextView.text = ""
        }

        // ViewController 를 TextView의 Delegate로 지정
        memoTextView.delegate = self

        // 키보드 notification 옵저버 등록
        // 키보드가 나타났을때
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                // height 에 키보드 높이를 저장
                let height = frame.cgRectValue.height
                var inset = strongSelf.memoTextView.contentInset
                
                inset.bottom = height // content view bottom 여백을 height 로 변경
                strongSelf.memoTextView.contentInset = inset // bottom 을 제외한 여백은 그대로 유지
                
                // 같은 방식으로 스크롤 바에도 height 만큼의 여백 추가
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
        })
        
        // 키보드가 사라졌을때
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.memoTextView.contentInset
            
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // First Responder: 입력포커스를 가진 View
        // 화면이 나타날때 입력 포커스 지정
        memoTextView.becomeFirstResponder()
        
        // 편집 화면이 나타날때 Delegate 가 self로 설정됨
        navigationController?.presentationController?.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 화면이 사라지면 입력 포커스 해제
        memoTextView.resignFirstResponder()
        
        // 편집 화면이 사라지면 Delegate가 nil로 설정됨
        navigationController?.presentationController?.delegate = nil
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

extension ComposeViewController: UITextViewDelegate {
    // 메모가 편집 될 때마다 실행
    func textViewDidChange(_ textView: UITextView) {
        // original과 다른지 비교 후 isModalInPresentation의 값을 변경함
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) { // for ios 13
                isModalInPresentation = original != edited
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    // 메모 수정 후 seet 를 pull down 했을 때 경고창을 표시함
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in
            self?.save(action)
        }
        alert.addAction(okAction) // alert 컨트롤러에 okAction을 추가함

        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in
            self?.close(action)
        }
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
