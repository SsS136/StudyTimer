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
    
    enum Mode {
        case entire
        case subject
    }
    var mode:Mode = .subject
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 7
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupCell(_ subject:Subject,mode:StudyPageViewController.Mode) {
        self.subject = subject
        self.mode = .subject
        self.backgroundColor = .whiteBlack
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
            $0.text = self.subject.title
            $0.textAlignment = .left
        }
        let time = CellLabel().then {
            switch mode {
            case .remaining:
                $0.text = "残り" + convertMiniteToHour(self.subject.remainingTime)
            case .current:
                $0.text = "現在" + convertMiniteToHour(self.subject.currentTime)
            }
        }
        let pg = CellLabel().then {
            $0.text = "進捗"
            $0.font = .systemFont(ofSize: 12)
            $0.textAlignment = .left
        }
        let progress = UIProgressView(progressViewStyle: .default).then {
            $0.progress = self.subject.progress
        }
        let remainP = CellLabel().then {
            $0.font = .systemFont(ofSize: 12)
            $0.text = "\(Int(round(self.subject.progress * 100)))％"
            $0.textAlignment = .right
        }
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
    func setupFirstCell(_ entire:Entire,mode:StudyPageViewController.Mode) {
        self.entire = entire
        self.mode = .entire
        self.backgroundColor = .clear
        let largeVstack = VStack(frame: .zero).then {
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        self.addSubview(largeVstack)
        let total = StateView(entire: entire, mode: mode, onText: "トータル")
        
        let month = StateView(month: Month.shared, mode: mode, onText: "\(Calendar.current.component(.month, from: Date()))月")
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
extension UIStackView {
    func addArrangedSubViews(views: [UIView]) {
        removeAllArrangedSubviews()
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({$0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}


class StateView : UIView, TimeConverter {
    
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
    func enableConstraints() {
        if month == nil {
            
            self.backgroundColor = .clear
            let vstack = VStack(frame: .zero).then {
                $0.alignment = .center
                $0.distribution = .equalSpacing
            }
            let hstack = HStack(frame:.zero).then {
                $0.alignment = .center
                $0.distribution = .equalSpacing
            }
            self.addSubview(hstack)
            
            
            hstack.snp.makeConstraints {
                $0.left.equalToSuperview().offset(10)
                $0.right.equalToSuperview().offset(-10)
                $0.top.bottom.equalToSuperview()
            }
            let circle = KYCircularProgress(frame: .zero, showGuide: true).then {
                $0.set(progress: Double(self.entire.entireProgress), duration: 0.1)
                $0.colors = [.red]
                $0.transform = CGAffineTransform(scaleX: -1, y: -1)
            }
            let percent = UILabel().then {
                $0.text = "\(Int(self.entire.entireProgress * 100))%"
                $0.textAlignment = .center
                $0.textColor = .blackWhite
                $0.font = .boldSystemFont(ofSize: 16)
                $0.transform = CGAffineTransform(scaleX: -1, y: -1)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                circle.addSubview(percent)
                percent.snp.makeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                    $0.width.equalTo(60)
                    $0.height.equalTo(20)
                }
            }
            let remain = UILabel().then {
                switch mode {
                case .remaining:
                    $0.text = onText + "残り"
                case .current:
                    $0.text = onText + "現在"
                }
                $0.textAlignment = .left
                $0.font = .boldSystemFont(ofSize: 25)
                $0.adjustsFontSizeToFitWidth = true
                $0.textColor = .black
            }
            let hours = UILabel().then {
                switch mode {
                case .remaining:
                    $0.text = convertMiniteToHour(self.entire.entireRemainingTime)
                case .current:
                    $0.text = convertMiniteToHour(self.entire.entireCurrentTime)
                }
                $0.adjustsFontSizeToFitWidth = true
                $0.textAlignment = .right
                $0.font = .boldSystemFont(ofSize: 30)
                $0.textColor = .black
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
            let vstack = VStack(frame: .zero).then {
                $0.alignment = .center
                $0.distribution = .equalSpacing
            }
            let hstack = HStack(frame:.zero).then {
                $0.alignment = .center
                $0.distribution = .equalSpacing
            }
            self.addSubview(hstack)
            
            
            hstack.snp.makeConstraints {
                $0.left.equalToSuperview().offset(10)
                $0.right.equalToSuperview().offset(-10)
                $0.top.bottom.equalToSuperview()
            }
            let circle = KYCircularProgress(frame: .zero, showGuide: true).then {
                $0.set(progress: Double(self.month.monthProgress), duration: 0.1)
                $0.colors = [.red]
                $0.transform = CGAffineTransform(scaleX: -1, y: -1)
            }
            let percent = UILabel().then {
                $0.text = "\(Int(self.month.monthProgress * 100))%"
                $0.textAlignment = .center
                $0.textColor = .blackWhite
                $0.font = .boldSystemFont(ofSize: 16)
                $0.transform = CGAffineTransform(scaleX: -1, y: -1)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                circle.addSubview(percent)
                percent.snp.makeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                    $0.width.equalTo(60)
                    $0.height.equalTo(20)
                }
            }
            let remain = UILabel().then {
                switch mode {
                case .remaining:
                    $0.text = onText + "残り"
                case .current:
                    $0.text = onText + "現在"
                }
                $0.textAlignment = .left
                $0.font = .boldSystemFont(ofSize: 25)
                $0.textColor = .black
            }
            let hours = UILabel().then {
                switch mode {
                case .remaining:
                    $0.text = convertMiniteToHour(self.month.monthRemainingTime)
                case .current:
                    $0.text = convertMiniteToHour(self.month.monthCurrentTime)
                }
                $0.adjustsFontSizeToFitWidth = true
                $0.textAlignment = .right
                $0.font = .boldSystemFont(ofSize: 30)
                $0.textColor = .black
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
