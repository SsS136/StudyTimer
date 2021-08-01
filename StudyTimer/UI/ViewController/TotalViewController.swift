//
//  TotalViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/17.
//

import UIKit
import KYCircularProgress

class TotalViewController : UIViewController, TimeConverter {
    
    private var leftBarButton:UIBarButtonItem!
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    var titleElement:[[String]] = {
        var arr = [["目標勉強時間","トータル残り","トータル勉強時間","一日の平均勉強時間","最終到達日程","最終到達日程までの一日平均勉強時間"],["目標勉強時間","月残り勉強時間","月トータル勉強時間","月末までの一日勉強時間"]]
        let date = DataSaver.studyTimePerDay.map { $0.map{(key,value) in key } }
        arr.append(date ?? [])
        return arr
    }()
    
    lazy var detailedText:[[String]] = {
        var arr = [[convertMiniteToHour(DataSaver.entire.entireBaseTime),convertMiniteToHour(DataSaver.entire.entireRemainingTime),convertMiniteToHour(DataSaver.entire.entireCurrentTime),convertMiniteToHour(Int(DataSaver.dayAve)),DateUtils.stringFromDate(date: DataSaver.atLastDate, format: "yyyy年MM月dd日"),studyTimePerDayUntilTheLastDateOfArrival(remainingTime: DataSaver.entire.entireRemainingTime)],[convertMiniteToHour(DataSaver.month.monthBaseTime),convertMiniteToHour(DataSaver.month.monthRemainingTime),convertMiniteToHour(DataSaver.month.monthCurrentTime),studyTimePerDayUntilTheLastDateOfArrival(remainingTime: DataSaver.month.monthRemainingTime, date: getLastDateOfThisMonth())]]
        let times = DataSaver.studyTimePerDay.map { $0.map {(key,value) in convertMiniteToHour(value) } }
        arr.append(times ?? [])
        return arr
    }()
    
    var sectionTitles = ["全体","月","一日の勉強時間"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarItems()
        setupTableView()
    }
    private func setupNavigationBarItems() {
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationItem.title = "詳細"
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.top.bottom.left.right.equalToSuperview() }
    }
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TotalViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleElement[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Subject")
//        if (indexPath.section == 0 || indexPath.section == 1) && indexPath.row == 0 {
//            cell = ProgressTableViewCell(type: indexPath.section == 0 ? .Entire : .Month, style: .subtitle, reuseIdentifier: "Subject")
//            cell.frame = CGRect(x: cell.frame.minX, y: cell.frame.minY, width: cell.frame.width, height: 58)
//        }
        cell.textLabel?.text = titleElement[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = detailedText[indexPath.section][indexPath.row]
        cell.detailTextLabel?.textColor = .gray
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

class ProgressTableViewCell : UITableViewCell {
    
    enum `Type` {
        case Entire
        case Month
    }
    
    init(type:Type,style: UITableViewCell.CellStyle = .subtitle, reuseIdentifier: String? = "Subtitle") {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupProgressView(type: type)
    }

    private func setupProgressView(type:Type) {
        let percent = UILabel().then {
            $0.text = "\(Int((type == .Entire ? Double(DataSaver.entire.entireProgress) : Double(DataSaver.month.monthProgress)) * 100))%"
            $0.textAlignment = .center
            $0.textColor = .black
            $0.font = .boldSystemFont(ofSize: 18)
        }
        self.addSubview(percent)
        percent.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-5)
            $0.width.equalTo(60)
            $0.height.lessThanOrEqualTo(18)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//class TotalViewController : FormViewController, TimeConverter, ErrorAlert {
//
//    private var leftBarButton:UIBarButtonItem!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBarItems()
//        guard DataSaver.atLastDate != nil else {
//            showErrorAlert(title: "最終到達日程を設定してください") { _ in
//                self.dismiss(animated: true, completion: nil)
//            }
//            return
//        }
//        form +++ Section("")
//            <<< TotalProgressRow() {
//                $0.cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//                $0.cell.layer.shadowColor = UIColor.darkGray.cgColor
//                $0.cell.layer.shadowOpacity = 0.4
//                $0.cell.layer.shadowRadius = 4
//                $0.cell.backgroundColor = $0.cell.superview?.backgroundColor
//                $0.cell.selectionStyle = .none
//
//            }
//            <<< LabelRow() {
//                $0.title = "トータル勉強時間"
//                $0.value = "\(convertMiniteToHour(DataSaver.entire.entireCurrentTime))"
//            }
//            <<< LabelRow() {
//                $0.title = "一日の平均勉強時間"
//                $0.value = convertMiniteToHour(Int(DataSaver.dayAve))
//            }
//            <<< LabelRow() {
//                $0.title = "最終到達日程"
//                $0.value = DateUtils.stringFromDate(date: DataSaver.atLastDate, format: "yyyy年MM月dd日")
//            }
//            <<< LabelRow() {
//                $0.title = "最終到達日程までの1日勉強時間"
//                $0.value = studyTimePerDayUntilTheLastDateOfArrival(remainingTime: DataSaver.entire.entireRemainingTime)
//            }
//    }
//
//    private func setupNavigationBarItems() {
//        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
//        self.navigationItem.title = "詳細"
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.barTintColor = .dynamicDark
//        self.navigationItem.leftBarButtonItem = leftBarButton
//    }
//    @objc func dismissController() {
//        self.dismiss(animated: true, completion: nil)
//    }
//}

protocol ErrorAlert where Self:UIViewController {}
extension ErrorAlert {
    func showErrorAlert(title:String,handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "", message: title, preferredStyle:.alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: handler)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
