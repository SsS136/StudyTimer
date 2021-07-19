//
//  NewSubjectController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/14.
//

import UIKit
import Eureka

protocol NewSubjectControllerDelegate : AnyObject {
    func reloadCollectionView()
}

class NewSubjectController : FormViewController, TimeConverter, ErrorAlert {
    
    weak var delegate:NewSubjectControllerDelegate!
    
    var leftBarButton:UIBarButtonItem!
    var rightBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .dynamicDark
        setupNavigationBarItems()
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "教科"
                row.placeholder = "教科を入力してください"
            }
            +++ Section("目標時間設定")
            <<< PhoneRow(){
                $0.title = "時間"
                $0.placeholder = "時間を入力してください"
            }
            <<< PhoneRow() {
                $0.title = "分"
                $0.placeholder = "分を入力してください"
            }
    }
    private func setupNavigationBarItems() {
        rightBarButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveSubjectData))
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = "新しく教科を追加する"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }

    @objc func saveSubjectData() {
        if DataSaver.subjects == nil {
            DataSaver.subjects = []
        }
        guard let subject = form.allRows[0].baseValue as? String else { showErrorAlert(title: "教科が正しく入力されていません"); return }
        guard DataSaver.subjects.map({ $0.title }).firstIndex(of: subject) == nil else { showErrorAlert(title: "すでにこの科目名は登録されています"); return }
        guard let hours = NumberFormatter().number(from: form.allRows[1].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "時間が正しく入力されていません"); return }
        guard let minites = NumberFormatter().number(from: form.allRows[2].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "分が正しく入力されていません" ); return }
        guard (hours != 0 || minites != 0) else { showErrorAlert(title: "勉強時間を正しく入力してください"); return }
        guard minites < 60 else { showErrorAlert(title: "分は60未満に設定してください"); return }
        
        DataSaver.subjects.append(Subject(title: subject, baseTime: convertHourToMinite(hour: hours, minite: minites), currentTime: 0))
        
        self.delegate.reloadCollectionView()
        dismissController()
        
    }
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
