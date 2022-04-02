//
//  UIViewController+Alert.swift
//  simpleMemo
//
//  Created by hhj on 2022/04/02.
//

import UIKit

extension UIViewController {
    func alert(title: String = "알림", message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        // alert 화면에 표시
        present(alert, animated: true, completion: nil)
    }
}
