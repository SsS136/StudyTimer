//
//  NewSubjectController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/14.
//

import UIKit
import TextFieldEffects

protocol NewSubjectControllerDelegate : AnyObject {
    func reloadCollectionView()
}

class NewSubjectController : UIViewController, TimeConverter {
    
    weak var delegate:NewSubjectControllerDelegate!
    
    var leftBarButton:UIBarButtonItem!
    var rightBarButton:UIBarButtonItem!
    
    var subjectTextField = MinoruTextField(frame: .zero).then {
        $0.placeholder = "教科"
        $0.placeholderColor = .gray
        $0.backgroundColor = .lightGray
        $0.textColor = .cyan
    }
    var baseHours = MinoruTextField(frame: .zero).then {
        $0.placeholder = "時間"
        $0.placeholderColor = .gray
        $0.textColor = .cyan
        //$0.borderActiveColor = .cyan
        $0.backgroundColor = .lightGray
        $0.keyboardType = .numberPad
    }
    var baseMinites = MinoruTextField(frame: .zero).then {
        $0.placeholder = "分"
        $0.textColor = .cyan
        $0.placeholderColor = .gray
        //$0.borderActiveColor = .cyan
        $0.backgroundColor = .lightGray
        $0.keyboardType = .numberPad
    }
    lazy var hstack = HStack().then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.addArrangedSubViews(views: [baseHours,baseMinites])
    }
    lazy var vstack = VStack().then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.addArrangedSubViews(views: [subjectTextField,hstack])
        $0.layer.cornerRadius = 6
        $0.backgroundColor = .whiteBlack
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowColor = UIColor.darkGray.cgColor
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius = 4
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "新しく教科を追加する"
        self.view.backgroundColor = .dynamicDark
        setupNavigationBarItems()
        setupTextFields()
    }
    private func setupNavigationBarItems() {
        rightBarButton = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(saveSubjectData))
        leftBarButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(dismissController))
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barTintColor = .dynamicDark
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    func setupTextFields() {
        self.view.addSubview(vstack)
        vstack.snp.makeConstraints {
            $0.top.equalTo(view).offset(100)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(view).multipliedBy(0.85)
            $0.height.equalTo(200)
        }
        hstack.snp.makeConstraints {
            $0.height.equalToSuperview().multipliedBy(0.5)
            $0.left.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-10)
        }
        subjectTextField.snp.makeConstraints {
            $0.left.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-10)
            $0.height.equalTo(60)
            $0.top.equalToSuperview().offset(10)
        }
        baseHours.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(60)
        }
        baseMinites.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(60)
        }
    }
    @objc func saveSubjectData() {
//        guard let min = baseMinites.text, let hour = baseHours.text else {
//            let alert = UIAlertController(title: "", message: "正しく時間が入力されていません", preferredStyle: .alert)
//            let action = UIAlertAction(title: "直す", style: .cancel, handler: nil)
//            alert.addAction(action)
//            self.present(alert, animated: true, completion: nil)
//            return
//        }

        var min = baseMinites.text ?? "0"
        var hour = baseHours.text ?? "0"
        min = min == "" ? "0" : min
        hour = hour == "" ? "0" : hour
        guard (NumberFormatter().number(from: min) as! Int) < 60 else {
            let alert = UIAlertController(title: "", message: "正しく分が入力されていません", preferredStyle: .alert)
            let action = UIAlertAction(title: "直す", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard subjectTextField.text != "" && subjectTextField.text != nil else {
            let alert = UIAlertController(title: "", message: "正しく教科が入力されていません", preferredStyle: .alert)
            let action = UIAlertAction(title: "直す", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }

        if let hourNum = NumberFormatter().number(from: hour) as? Int, let minNum = NumberFormatter().number(from: min) as? Int {
            if DataSaver.subjects == nil {
                DataSaver.subjects = []
            }
            DataSaver.subjects.append(Subject(title: subjectTextField.text ?? "-", baseTime: convertHourToMinite(hour: hourNum, minite: minNum), currentTime: 0))
            self.dismiss(animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.delegate.reloadCollectionView()
            }
        }else{
            let alert = UIAlertController(title: "", message: "エラーが発生しました", preferredStyle: .alert)
            let action = UIAlertAction(title: "直す", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}
