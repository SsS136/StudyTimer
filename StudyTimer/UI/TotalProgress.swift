//
//  TotalProgress.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/17.
//

import UIKit
import Eureka
import KYCircularProgress

//月平均もだす

public class TotalProgressCell: Cell<Bool>, CellType, TimeConverter {
    
    let hstack = HStack().then {
        $0.alignment = .center
        $0.distribution = .equalSpacing
    }
    let vstack = VStack().then {
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    private let totalRemaining = CellLabel().then {
        $0.text = "トータル残り"
        $0.font = .boldSystemFont(ofSize: 25)
        $0.textAlignment = .left
        $0.textColor = .black
    }
    private lazy var times = CellLabel().then {
        $0.text = convertMiniteToHour(DataSaver.entire.entireRemainingTime)
        $0.textAlignment = .right
        $0.font = .boldSystemFont(ofSize: 30)
        $0.textColor = .black
    }
    private let circleProgress = KYCircularProgress(frame: .zero, showGuide: true).then {
        $0.set(progress: Double(DataSaver.entire.entireProgress), duration: 0.1)
        $0.colors = [.red]
        $0.transform = CGAffineTransform(scaleX: -1, y: -1)
    }
    let percent = UILabel().then {
        $0.text = "\(Int(DataSaver.entire.entireProgress * 100))%"
        $0.textAlignment = .center
        $0.textColor = .black
        $0.font = .boldSystemFont(ofSize: 18)
        $0.transform = CGAffineTransform(scaleX: -1, y: -1)
    }
    public override func setup() {
        super.setup()
        self.addSubview(vstack)
        self.backgroundColor = .white
        self.layer.cornerRadius = 7
        self.snp.makeConstraints {
            $0.width.equalTo(UX.width)
            $0.height.equalTo(270)
        }
        vstack.addArrangedSubViews(views: [hstack,circleProgress])
        hstack.addArrangedSubViews(views: [totalRemaining,times])
        vstack.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        hstack.snp.makeConstraints {
            $0.width.equalTo(vstack).offset(-15)
            $0.height.equalTo(vstack).multipliedBy(0.3)
        }
        circleProgress.snp.makeConstraints {
            $0.height.equalTo(vstack).multipliedBy(0.7)
            $0.width.equalTo(vstack.snp.height).multipliedBy(0.7)
        }
        totalRemaining.snp.makeConstraints {
            $0.width.height.lessThanOrEqualToSuperview()
        }
        times.snp.makeConstraints {
            $0.width.height.lessThanOrEqualToSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {[self] in
            circleProgress.addSubview(percent)
            percent.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.width.equalTo(60)
                $0.height.lessThanOrEqualTo(20)
            }
        }
    }

    public override func update() {
        super.update()
    }
}
public final class TotalProgressRow: Row<TotalProgressCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        //cellProvider = CellProvider<TotalProgressCell>(nibName: "CustomCell")
    }
}
