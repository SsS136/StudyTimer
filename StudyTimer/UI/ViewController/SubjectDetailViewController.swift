//
//  SubjectDetailViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/22.
//

import UIKit

protocol SubjectDetailViewControllerDelegate : AnyObject {
    func reloadCollectionView()
}

class SubjectDetailViewController : UIViewController, TimeConverter, ErrorAlert {
    
    private var leftBarButton:UIBarButtonItem!
    private var rightBarButton:UIBarButtonItem!
    
    ///This variable must be initialized when the viewController instance is created.
    var subjectTitle:SubjectTitle!
    
    weak var delegate:SubjectDetailViewControllerDelegate!
    
    lazy var _history = {[unowned self] () -> [Dictionary<DateString, [Int]>.Element]? in
        guard subjectTitle != nil else { return [] }
        guard DataSaver.dayStudy != nil else {
            showErrorAlert(title: "最終到達日程を設定してください", handler: {_ in
                let date = DateViewController()
                date.delegate = self
                self.navigationController?.pushViewController(date, animated: true)
            })
            return []
        }
        let h = DataSaver.dayStudy[subjectTitle] ?? [:]
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日"
        let result = h.sorted {
            df.date(from: $0.0)! > df.date(from: $1.0)!
        }
        return result
    }
    
    private var dateElement:[String] {
        get {
            let a = history.map {(key) in
                key.map {(key,value) -> [String] in
                    var arr = [String]()
                    for _ in 0..<value.count {
                        arr.append(key)
                    }
                    return arr
                }
            }
            let b = a?.flatMap {$0}
            return b ?? []
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var headerTitles = ["詳細","履歴\(dateElement.count == 0 ? "はありません" : "")"]
    
    private lazy var _tableViewElements = { () -> [[String]] in
        var el = [["目標時間","残りの勉強時間","現在の勉強時間","一日平均勉強時間","最終到達日程までの一日平均勉強時間"]]
        el.append(self.dateElement)
        return el
    }
    
    
    lazy var _detailedText = {[self] () -> [[String]] in
        
        let base = DataSaver.subjects.filter { $0.title == subjectTitle }[0]
        baseTime = base.baseTime
        var el = [[convertMiniteToHour(base.baseTime),convertMiniteToHour(base.remainingTime),convertMiniteToHour(base.currentTime),convertMiniteToHour(DataSaver.subjectDayAverage(dayStudy:history ?? [])),studyTimePerDayUntilTheLastDateOfArrival(remainingTime: base.remainingTime)]]
        let times = history.map {
            $0.map { (key,value) in
                value
            }
        }
        let flatTimes = times?.flatMap { $0 }.map {
            convertMiniteToHour($0)
        } ?? []
        historyTime = times?.flatMap {$0} ?? []
        el.append(flatTimes)
        
        return el
    }
    
    //if you want to reload this page, reassign these variables
    private lazy var detailedText = _detailedText()
    private lazy var history = _history()
    private lazy var tableViewElements = _tableViewElements()
    
    private lazy var historyTime = [Int]()
    private lazy var baseTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        setupTableView()
    }
    func reloadPage() {
        
        history = _history()
        detailedText = _detailedText()
        tableViewElements = _tableViewElements()
        
        tableView.reloadData()
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.top.bottom.left.right.equalToSuperview() }
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        rightBarButton = UIBarButtonItem(title: "記録する", style: .plain, target: self, action: #selector(recordStudyTime))
        self.navigationItem.title = subjectTitle
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func recordStudyTime() {
        let edit = EditViewController()
        edit.delegate = self
        edit.initialValue = subjectTitle
        self.navigationController?.pushViewController(edit, animated: true)
    }
}
extension SubjectDetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewElements[section].count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitles[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Subject")
        cell.textLabel?.text = tableViewElements[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = detailedText[indexPath.section][indexPath.row]
        cell.detailTextLabel?.textColor = .gray
        
        if indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 0 ){
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }else{
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section != 0 || indexPath.row != 0 else {
            let baseTimeUpdate = GoalTimeUpdateViewController()
            baseTimeUpdate.delegate = self
            baseTimeUpdate.time = baseTime
            baseTimeUpdate.subjectTitle = subjectTitle
        
            self.navigationController?.pushViewController(baseTimeUpdate, animated: true)
            return
        }
        guard indexPath.section == 1 else { return }
        
        let hisControlelr = HistoryUpdateViewController()
        
        hisControlelr.time = historyTime[indexPath.row]
        hisControlelr.subjectTitle = subjectTitle
        hisControlelr.date = tableViewElements[indexPath.section][indexPath.row]
        hisControlelr.delegate = self
        
        self.navigationController?.pushViewController(hisControlelr, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard indexPath.section != 0 else { return }
        
        if editingStyle == .delete {
            
            let date_t = tableViewElements[indexPath.section][indexPath.row]
            let time = historyTime[indexPath.row]
            
            if let index = DataSaver.dayStudy[subjectTitle]?[date_t]?.firstIndex(of: time),
               let base = DataSaver.subjects.filter({ $0.title == subjectTitle }).first,
               let indexS = DataSaver.subjects.firstIndex(of: base)
            {
                
                DataSaver.dayStudy[subjectTitle]?[date_t]?.remove(at: index)
                DataSaver.subjects[indexS].currentTime -= time
                DataSaver.month.monthCurrentTime -= time
                reloadPage()
                reloadCollectionView()
                
            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
}

extension SubjectDetailViewController : HistoryUpdateViewControllerDelegate, EditViewControllerDelegate, DateViewControllerDelegate, GoalTimeUpdateViewControllerDelegate {
    func reloadCollectionView() {
        self.delegate.reloadCollectionView()
    }
    func reloadDetails() {
        reloadPage()
    }
}
