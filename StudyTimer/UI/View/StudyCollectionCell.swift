//
//  StudyCollectionCell.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit
import KYCircularProgress

class StudyCollectionCell : UICollectionViewCell, TimeConverter {
    
    var subject:Subject!
    var entire:Entire!
    
    var isBlanked:Bool!
    
    enum Mode {
        case entire
        case subject
    }
    var mode:Mode = .subject
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = UX.generalCornerRadius
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupCell(_ subject:Subject,mode:StudyPageViewController.Mode) {
        self.subviews.forEach {
            $0.isHidden = true
        }
        self.subject = subject
        self.mode = .subject
        self.backgroundColor = .whiteBlack
        
        let stateView = StudyStateView(subject, mode: mode)
        stateView.layer.cornerRadius = UX.generalCornerRadius
        self.addSubview(stateView)
        
        stateView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
    
    let largeVstack = VStack(frame: .zero).then {
        $0.alignment = .center
        $0.distribution = .fillEqually
    }

    func setupFirstCell(_ entire:Entire,mode:StudyPageViewController.Mode) {
        self.entire = entire
        self.mode = .entire
        self.backgroundColor = .clear

        self.addSubview(largeVstack)
        let total = StateView(entire: entire, mode: mode, onText: "トータル")
        
        let month = StateView(month: DataSaver.month, mode: mode, onText: "\(Calendar.current.component(.month, from: Date()))月")
        largeVstack.addArrangedSubViews(views: [total,month])
        largeVstack.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.88)
        }
        total.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        month.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        total.enableConstraints()
        month.enableConstraints()
    }
    func setupBlank() {
        self.backgroundColor = .clear
        self.subviews.forEach {
            $0.isHidden = true
        }
    }
}

//MARK: StudyStateView
fileprivate class StudyStateView : UIView, TimeConverter {
    let vstack = VStack(frame: .zero).then {
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    let onHstack = HStack(frame: .zero).then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    let underHstack = HStack(frame: .zero).then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    let subjectLabel = CellLabel().then {
        $0.textAlignment = .left
    }
    let time = CellLabel()
    let pg = CellLabel().then {
        $0.text = "進捗"
        $0.font = .systemFont(ofSize: 12)
        $0.textAlignment = .left
    }
    let remainP = CellLabel().then {
        $0.font = .systemFont(ofSize: 12)
        $0.textAlignment = .right
    }
    let progress = UIProgressView(progressViewStyle: .default)
    var subject:Subject!
    var entire:Entire!
    init(_ subject:Subject,mode:StudyPageViewController.Mode) {
        super.init(frame: .zero)
        self.subject = subject
        self.backgroundColor = .whiteBlack
        
        subjectLabel.text = self.subject.title
        
        switch mode {
        case .remaining:
            time.text = "残り" + convertMiniteToHour(self.subject.remainingTime)
        case .current:
            time.text = "現在" + convertMiniteToHour(self.subject.currentTime)
        }
        progress.progress = self.subject.progress
        remainP.text = "\(Int(round(self.subject.progress * 100)))％"
        self.addSubview(vstack)
        
        vstack.addArrangedSubViews(views: [onHstack,underHstack])
        onHstack.addArrangedSubViews(views: [subjectLabel,time])
        underHstack.addArrangedSubViews(views: [pg,progress,remainP])
        
        vstack.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        onHstack.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-22)
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        underHstack.snp.makeConstraints {
            $0.width.equalToSuperview().offset(-22)
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        subjectLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(45)
        }
        time.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(60)
        }
        pg.snp.makeConstraints {
            $0.width.equalTo(45)
        }
        remainP.snp.makeConstraints {
            $0.width.equalTo(49)
        }
        progress.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.6)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class HStack : UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class VStack : UIStackView {
    override init(frame:CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class CellLabel : UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = .center
        self.font = .boldSystemFont(ofSize: 13.5)
        self.textColor = .black
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: StateView
fileprivate class StateView : UIView, TimeConverter {
    
    var entire:Entire!
    var mode:StudyPageViewController.Mode
    var month:Month!
    var onText:String!
    
    init(entire:Entire,mode:StudyPageViewController.Mode,onText:String) {
        
        self.entire = entire
        self.onText = onText
        self.mode = mode
        super.init(frame: .zero)

    }
    let vstack = VStack(frame: .zero).then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    let hstack = HStack(frame:.zero).then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    let circle = KYCircularProgress(frame: .zero, showGuide: true).then {
        $0.colors = [.red]
        $0.transform = CGAffineTransform(scaleX: -1, y: -1)
    }
    let percent = UILabel().then {

        $0.textAlignment = .center
        $0.textColor = .blackWhite
        $0.font = .boldSystemFont(ofSize: 16)
        $0.transform = CGAffineTransform(scaleX: -1, y: -1)
    }
    let remain = UILabel().then {
        $0.textAlignment = .left
        $0.font = .boldSystemFont(ofSize: 25)
        $0.adjustsFontSizeToFitWidth = true
        $0.textColor = .black
    }
    let hours = UILabel().then {
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .right
        $0.font = .boldSystemFont(ofSize: 30)
        $0.textColor = .black
    }
    func enableConstraints() {
        if self.entire == nil {self.entire = Entire(entireBaseTime: 0, entireCurrentTime: 0)}
        if month == nil {
            
            self.backgroundColor = .clear

            self.addSubview(hstack)
            circle.set(progress: Double(self.entire.entireProgress), duration: 0.1)

            percent.text = "\(Int(self.entire.entireProgress * 100))%"
            
            hstack.snp.makeConstraints {
                $0.left.equalToSuperview().offset(10)
                $0.right.equalToSuperview().offset(-10)
                $0.top.bottom.equalToSuperview()
            }
            hstack.addArrangedSubViews(views: [vstack,circle])
            vstack.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.48)
                $0.height.equalToSuperview().multipliedBy(0.6)
            }
            circle.snp.makeConstraints {
                $0.height.equalTo(hstack).multipliedBy(0.77)
                $0.width.equalTo(hstack.snp.height).multipliedBy(0.77)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {[self] in
                circle.addSubview(percent)
                percent.snp.makeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                    $0.width.equalTo(60)
                    $0.height.equalTo(20)
                }
            }

            switch mode {
            case .remaining:
                remain.text = onText + "残り"
                hours.text = convertMiniteToHour(self.entire.entireRemainingTime)
            case .current:
                remain.text = onText + "現在"
                hours.text = convertMiniteToHour(self.entire.entireCurrentTime)
            }
            
            vstack.addArrangedSubViews(views: [remain,hours])
            remain.snp.makeConstraints {
                $0.width.equalTo(vstack)
                $0.height.equalTo(30)
            }
            hours.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(40)
            }
        }else{
            
            self.backgroundColor = .clear
            self.addSubview(hstack)
            
            
            hstack.snp.makeConstraints {
                $0.left.equalToSuperview().offset(10)
                $0.right.equalToSuperview().offset(-10)
                $0.top.bottom.equalToSuperview()
            }

            circle.set(progress: Double(self.month.monthProgress), duration: 0.1)
            percent.text = "\(Int(self.month.monthProgress * 100))%"
            hstack.addArrangedSubViews(views: [vstack,circle])
            vstack.snp.makeConstraints {
                $0.width.equalToSuperview().multipliedBy(0.48)
                $0.height.equalToSuperview().multipliedBy(0.6)
            }
            circle.snp.makeConstraints {
                $0.height.equalTo(hstack).multipliedBy(0.77)
                $0.width.equalTo(hstack.snp.height).multipliedBy(0.77)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {[self] in
                circle.addSubview(percent)
                percent.snp.makeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                    $0.width.equalTo(60)
                    $0.height.equalTo(20)
                }
            }
            
            switch mode {
            case .remaining:
                remain.text = onText + "残り"
                hours.text = convertMiniteToHour(self.month.monthRemainingTime)
            case .current:
                remain.text = onText + "現在"
                hours.text = convertMiniteToHour(self.month.monthCurrentTime)
            }

            vstack.addArrangedSubViews(views: [remain,hours])
            remain.snp.makeConstraints {
                $0.width.equalTo(vstack)
                $0.height.equalTo(30)
            }
            hours.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(40)
            }
        }
    }
    init(month:Month,mode:StudyPageViewController.Mode,onText:String) {
        
        self.month = month
        self.mode = mode
        self.onText = onText
        super.init(frame: .zero)

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
