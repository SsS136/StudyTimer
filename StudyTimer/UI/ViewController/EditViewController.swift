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
class EditViewController : FormViewController, TimeConverter, ErrorAlert {
    
    private let subjects:[String] = {
        guard DataSaver.subjects != nil else { return [String]() }
        return DataSaver.subjects.map { $0.title }
    }()
    
    private var leftBarButton:UIBarButtonItem!
    private var rightBarButton:UIBarButtonItem!
    
    ///Assign to this variable if you need the initial value of the subject
    var initialValue:String!
    
    var timerView = StopWatchView()
    var minite:Int!
    
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
        setupTableView()
        setupTimerView()
    }
    private func setupTableView() {
        form +++ Section("編集")
            <<< PickerRow<String>(){ row in
                row.title = "教科"
                row.options = subjects
                row.value = initialValue == nil ? subjects[0] : initialValue
            }
            .onChange {
                UserDefaults.standard.setValue($0.value, forKey: "LastSubject")
            }
            <<< DateRow() {
                $0.title = "日時"
                $0.value = Date()
            }
            <<< PhoneRow(){
                $0.title = "時間"
                $0.placeholder = "時間を入力してください"
                if minite != nil {
                    $0.value = "\(extractHourAndMinitefromMinite(minite).0)"
                }
            }
            <<< PhoneRow() {
                $0.title = "分"
                $0.placeholder = "分を入力してください"
                if minite != nil {
                    $0.value = "\(extractHourAndMinitefromMinite(minite).1)"
                }
            }
    }
    private func setupTimerView() {
        self.view.addSubview(timerView)
        
        timerView.delegate = self
        
        timerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        timerView.layer.shadowColor = UIColor.darkGray.cgColor
        timerView.layer.shadowOpacity = 0.4
        timerView.layer.shadowRadius = 4
        
        timerView.snp.makeConstraints {
            $0.height.equalTo(150)
            $0.width.equalToSuperview().multipliedBy(0.92)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
        }
    }
    @objc private func recordSubjectData() {
        
        if DataSaver.dayStudy == nil {
            DataSaver.dayStudy = [:]
        }
        //detect some error
        guard let subject = form.allRows[0].baseValue as? String else { showErrorAlert(title: "教科が正しく入力されていません"); return }
        guard let date = form.allRows[1].baseValue as? Date else { showErrorAlert(title: "日にちが正しく入力されていません"); return }
        guard let hours = NumberFormatter().number(from: form.allRows[2].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "時間が正しく入力されていません"); return }
        guard let minites = NumberFormatter().number(from: form.allRows[3].baseValue as? String ?? "0") as? Int else { showErrorAlert(title: "分が正しく入力されていません" ); return }
        guard let index = subjects.firstIndex(of: subject) else { showErrorAlert(title: "データがありません"); return }
        guard (hours != 0 || minites != 0) else { showErrorAlert(title: "勉強時間を正しく入力してください"); return }
        guard minites < 60 else { showErrorAlert(title: "分は60未満に設定してください"); return }
        guard convertHourToMinite(hour: hours, minite: minites) + DataSaver.subjects[index].currentTime <= DataSaver.subjects[index].baseTime else { showErrorAlert(title: "目標勉強時間以上の勉強時間を設定することはできません"); return }

        let totalMin = convertHourToMinite(hour: hours, minite: minites)
        
        //reload saved subjects data
        DataSaver.subjects[index].title = subject
        DataSaver.subjects[index].currentTime += totalMin
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMM", options: 0, locale: Locale(identifier: "ja_JP"))
        let dateString = formatter.string(from: date)
        
        if DataSaver.dayStudy[DataSaver.subjects[index].title, default: [:]][dateString] == nil {
            DataSaver.dayStudy[DataSaver.subjects[index].title, default: [:]].updateValue([], forKey: dateString)
        }
        
        //add Todays study record
        DataSaver.dayStudy[DataSaver.subjects[index].title, default: [:]][dateString]?.insert(totalMin, at: 0)
        
        monthDataSetter()
        
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
        if initialValue == nil {
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        //timerView.timer.invalidate()
        UserDefaults.standard.setValue(false, forKey: "edit")
    }
}

extension EditViewController : StopWatchViewDelegate {
    func useTime(time: Int) {
        minite = time
        //tableView.removeFromSuperview()
        form.removeAll()
        setupTableView()
    }
}
