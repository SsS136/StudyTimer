//
//  DateViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/16.
//

import UIKit
import Eureka

class DateViewController : FormViewController {
    
    private var leftBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()

        form +++ Section("最終到達目標")
            <<< DateRow() {
                $0.title = "最終到達日時を設定する"
                $0.value = DataSaver.atLastDate
            }.onChange {
                DataSaver.atLastDate = $0.value!
            }
        
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = "カレンダー"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
