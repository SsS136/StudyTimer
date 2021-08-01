//
//  HistoryUpdateViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/22.
//

import UIKit
import Eureka

protocol HistoryUpdateViewControllerDelegate : AnyObject {
    func reloadCollectionView()
    func reloadDetails()
}

class HistoryUpdateViewController : FormViewController, TimeConverter, ErrorAlert {
    
    private var rightBarButton:UIBarButtonItem!
    
    ///This variable must be initialized when the viewController instance is created.
    var time:Int!
    var subjectTitle:SubjectTitle!
    var date:DateString! //aka String
    
    weak var delegate:HistoryUpdateViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        form +++ Section("時間変更")
            <<< PhoneRow() {
                $0.title = "時間"
                $0.value = "\(extractHourAndMinitefromMinite(time).0)"
            }
            <<< PhoneRow() {
                $0.title = "分"
                $0.value = "\(extractHourAndMinitefromMinite(time).1)"
            }
    }
    private func setupNavigationBarItems() {
        rightBarButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveState))
        
        self.navigationItem.title = "更新"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    @objc func dismissController() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func saveState() {
        guard let hoursBase = form.allRows[0].baseValue as? String,let hours = NumberFormatter().number(from: hoursBase) as? Int else { showErrorAlert(title: "時間が正しく入力されていません"); return }
        guard let minitesBase = form.allRows[1].baseValue as? String, let minites = NumberFormatter().number(from: minitesBase) as? Int else { showErrorAlert(title: "分が正しく入力されていません"); return }
        
        let index = DataSaver.dayStudy[subjectTitle]?[date]?.firstIndex(of: time ?? 0)
        let afmin = convertHourToMinite(hour: hours, minite: minites)
        DataSaver.dayStudy[subjectTitle]?[date]?[index ?? 0] = afmin
        
        if var baseSubject = DataSaver.subjects.filter({ $0.title == subjectTitle })[safe:0], let index = DataSaver.subjects.firstIndex(of: baseSubject) {
            
            let current = baseSubject.currentTime
            let after = current - time + afmin
            baseSubject.currentTime = after
            DataSaver.subjects[index] = baseSubject
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.delegate.reloadDetails()
            self.delegate.reloadCollectionView()
            
            self.dismissController()
        }
    }
}
