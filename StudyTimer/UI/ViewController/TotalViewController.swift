//
//  TotalViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/17.
//

import UIKit
import Eureka

class TotalViewController : FormViewController, TimeConverter {
    
    private var leftBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        guard DataSaver.atLastDate != nil else { showErrorAlert(title: "最終到達日程を設定してください"); return }
        form +++ Section("")
            <<< TotalProgressRow() {
                $0.cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                $0.cell.layer.shadowColor = UIColor.darkGray.cgColor
                $0.cell.layer.shadowOpacity = 0.4
                $0.cell.layer.shadowRadius = 4
                $0.cell.backgroundColor = $0.cell.superview?.backgroundColor
                $0.cell.selectionStyle = .none

            }
            <<< LabelRow() {
                $0.title = "トータル勉強時間"
                $0.value = "\(convertMiniteToHour(DataSaver.entire.entireCurrentTime))"
            }
            <<< LabelRow() {
                $0.title = "一日の平均勉強時間"
                $0.value = convertMiniteToHour(Int(DataSaver.dayAve))
            }
            <<< LabelRow() {
                $0.title = "最終到達日程"
                $0.value = DateUtils.stringFromDate(date: DataSaver.atLastDate, format: "yyyy年MM月dd日")
            }
            <<< LabelRow() {
                $0.title = "最終到達日程までの1日勉強時間"
                let elapsedDays = Calendar.current.dateComponents([.day], from: Date(), to: DataSaver.atLastDate).day!
                let mustStudy = DataSaver.entire.entireRemainingTime
                let aveTime = Int(Float(mustStudy) / Float(elapsedDays))
                $0.value = convertMiniteToHour(aveTime)
            }
    }
    private func showErrorAlert(title:String) {
        let alert = UIAlertController(title: "", message: title, preferredStyle:.alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = "詳細"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
