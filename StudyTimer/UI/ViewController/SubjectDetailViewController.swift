//
//  SubjectDetailViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/22.
//

import UIKit


class SubjectDetailViewController : UIViewController, TimeConverter {
    
    private var leftBarButton:UIBarButtonItem!
    
    ///This variable must be initialized when the viewController instance is created.
    var subjectTitle:String!
    
    lazy var history:[Dictionary<DateString, [Int]>.Element]? = {
        let h = DataSaver.dayStudy[subjectTitle]
        let df = DateFormatter()
        df.dateFormat = "yyyy年MM月dd日"
        let result = h?.sorted {
            df.date(from: $0.0)! > df.date(from: $1.0)!
        }
        return result
    }()
    
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
    
    private lazy var tableViewElements:[[String]] = {
        var el = [["目標時間","残りの勉強時間","現在の勉強時間","一日平均勉強時間","最終到達日程までの一日平均勉強時間"]]
        el.append(dateElement)
        return el
    }()
    
    lazy var detailedText:[[String]] = {
        let base = DataSaver.subjects.filter { $0.title == subjectTitle }[0]
        var el = [[convertMiniteToHour(base.baseTime),convertMiniteToHour(base.remainingTime),convertMiniteToHour(base.currentTime),convertMiniteToHour(DataSaver.subjectDayAverage(dayStudy:history ?? [])),studyTimePerDayUntilTheLastDateOfArrival(remainingTime: base.remainingTime)]]
        let times = history.map {
            $0.map { (key,value) in
                value
            }
        }
        let flatTimes = times?.flatMap { $0 }.map {
            convertMiniteToHour($0)
        } ?? []
        el.append(flatTimes)
        return el
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.top.bottom.left.right.equalToSuperview() }
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = subjectTitle
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc private func dismissController() {
        self.dismiss(animated: true, completion: nil)
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
        cell.selectionStyle = indexPath.section == 0 ? .none : .default
        if indexPath.section == 1 {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    
}
