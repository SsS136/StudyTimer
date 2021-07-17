//
//  EditViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/16.
//

import UIKit
import Eureka
protocol EditViewControllerDelegate : AnyObject {
    func reloadCollectionView()
}
class EditViewController : FormViewController, TimeConverter {
    
    private let subjects = DataSaver.subjects.map { $0.title }
    
    private var leftBarButton:UIBarButtonItem!
    private var rightBarButton:UIBarButtonItem!
    
    weak var delegate:EditViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        guard subjects.count != 0 else {
            showErrorAlert(title: "教科がありません") {_ in 
                self.dismiss(animated: true, completion: nil)
            }
            return
        }
        form +++ Section("編集")
            <<< PickerRow<String>(){ row in
                row.title = "教科"
                row.options = subjects
                row.value = subjects[0]
            }
            <<< PhoneRow(){
                $0.title = "時間"
                $0.placeholder = "時間を入力してください"
            }
            <<< PhoneRow() {
                $0.title = "分"
                $0.placeholder = "分を入力してください"
            }
    }
    private func showErrorAlert(title:String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: title, preferredStyle:.alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    @objc private func recordSubjectData() {
        
        if DataSaver.dayStudy == nil {
            DataSaver.dayStudy = [:]
        }

        guard let subject = form.allRows[0].baseValue as? String else { showErrorAlert(title: "教科が正しく入力されていません"); return }
        guard let hours = NumberFormatter().number(from: form.allRows[1].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "時間が正しく入力されていません"); return }
        guard let minites = NumberFormatter().number(from: form.allRows[2].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "分が正しく入力されていません" ); return }
        guard let index = subjects.firstIndex(of: subject) else { showErrorAlert(title: "データがありません"); return }
        guard (hours != 0 || minites != 0) else { showErrorAlert(title: "勉強時間を正しく入力してください"); return }
        guard minites < 60 else { showErrorAlert(title: "分は60未満に設定してください"); return }
        guard convertHourToMinite(hour: hours, minite: minites) + DataSaver.subjects[index].currentTime <= DataSaver.subjects[index].baseTime else { showErrorAlert(title: "目標勉強時間以上の勉強時間を設定することはできません"); return }

        let totalMin = convertHourToMinite(hour: hours, minite: minites)
        DataSaver.subjects[index].title = subject
        DataSaver.subjects[index].currentTime += totalMin
        if DataSaver.dayStudy[DataSaver.subjects[index], default: [:]][DataSaver.today] == nil {
            DataSaver.dayStudy[DataSaver.subjects[index], default: [:]][DataSaver.today] = []
        }
        DataSaver.dayStudy[DataSaver.subjects[index], default: [:]][DataSaver.today]?.append(totalMin)
        
        self.delegate.reloadCollectionView()
        dismissController()
        
    }
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupNavigationBarItems() {
        rightBarButton = UIBarButtonItem(title: "記録する", style: .plain, target: self, action: #selector(recordSubjectData))
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = "記録を追加する"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
}
