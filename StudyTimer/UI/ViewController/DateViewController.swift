//
//  DateViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/16.
//

import UIKit
import Eureka

protocol DateViewControllerDelegate : AnyObject {
    func reloadCollectionView()
}

class DateViewController : FormViewController, ErrorAlert, TimeConverter {
    
    private var leftBarButton:UIBarButtonItem!
    private var rightBarButton:UIBarButtonItem!
    
    weak var delegate:DateViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()

        form +++ Section("最終到達目標を設定する")
            <<< DatePickerRow() {
                $0.title = "最終到達日時を設定する"
                $0.value = DataSaver.atLastDate
            }
            +++ Section("\(Calendar.current.component(.month, from: Date()))月の目標設定")
            <<< PhoneRow() {
                $0.title = "時間"
                $0.placeholder = "時間を入力してください"
                $0.value = "\(extractHourAndMinitefromMinite(DataSaver.month.monthBaseTime).0)"
            }
            <<< PhoneRow() {
                $0.title = "分"
                $0.placeholder = "分を入力してください"
                $0.value = "\(extractHourAndMinitefromMinite(DataSaver.month.monthBaseTime).1)"
            }
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        rightBarButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveData))
        self.navigationItem.title = "目標"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func saveData() {
        let from = (form.allRows[1].baseValue ?? "0") as! String
        let fromM = (form.allRows[2].baseValue ?? "0") as! String
        guard let date = form.allRows[0].baseValue as? Date else { showErrorAlert(title: "日付が正しく入力されていません"); return }
        guard let basehour = NumberFormatter().number(from: from) as? Int, let baseMinite = NumberFormatter().number(from: fromM) as? Int else {
            showErrorAlert(title: "時間が正しく入力されていません")
            return
        }
        guard (basehour + baseMinite) != 0  else { showErrorAlert(title: "時間が正しく入力されていません"); return }
        guard baseMinite < 60 else { showErrorAlert(title: "時間は60分未満にしてください"); return }
        guard convertHourToMinite(hour: basehour, minite: baseMinite) <= DataSaver.entire.entireRemainingTime else { showErrorAlert(title: "目標時間は全体の残り時間以下の数にしてください"); return }
        
        DataSaver.atLastDate = date
        DataSaver.month = Month(monthBaseTime: convertHourToMinite(hour: basehour, minite: baseMinite), monthCurrentTime: monthDataSetter())
        
        self.delegate.reloadCollectionView()
        dismissController()
    }
}
