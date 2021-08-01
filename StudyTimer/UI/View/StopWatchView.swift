//
//  StopWatchView.swift
//  StudyTimer
//
//  Created by Ryu on 2021/08/01.
//

import UIKit
import DynamicButton

protocol StopWatchViewDelegate : AnyObject {
    func useTime(time:Int)
}

class StopWatchView : UIView, TimeConverter {
    
    enum State {
        case stop
        case play
    }
    
    weak var delegate:StopWatchViewDelegate!
    
    var useButton = DynamicButton(style: .checkMark)
    var startButton = DynamicButton(style: .play)
    var vstack = VStack(frame: .zero).then {
        $0.distribution = .fillProportionally
        $0.alignment = .center
    }
    var hstack = HStack(frame: .zero).then {
        $0.distribution = .equalSpacing
        $0.alignment = .center
    }
    var timeLabel = UILabel(frame: .zero).then {
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 28)
        $0.textColor = .black
        $0.text = "00:00:00"
    }
    
    var state:State = .stop
    
    
    private var elapsedTime = Float(0)
    private var minite = 0
    var timer:Timer!
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        NotificationCenter.default.addObserver(self, selector: #selector(reviveBackground(notification:)), name: Notification.Name("ela"), object: nil)
        setupViews()
        checkLastTerminal()
    }
    private func setupViews() {
        self.addSubview(vstack)
        
        startButton.addTarget(self, action: #selector(tappedStart), for: .touchUpInside)
        useButton.addTarget(self, action: #selector(useTime), for: .touchUpInside)
        
        vstack.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
        vstack.addArrangedSubViews(views: [timeLabel,hstack])
        timeLabel.snp.makeConstraints {
            $0.height.equalTo(vstack).multipliedBy(0.5)
            $0.width.equalTo(vstack).multipliedBy(0.9)
        }
        hstack.snp.makeConstraints {
            $0.height.equalTo(vstack).multipliedBy(0.5)
            $0.width.equalTo(vstack).multipliedBy(0.75)
        }
        hstack.addArrangedSubViews(views: [startButton,useButton])
        startButton.snp.makeConstraints { $0.width.height.equalTo(45) }
        useButton.snp.makeConstraints { $0.width.height.equalTo(45) }
    }
    
    @objc func reviveBackground(notification:Notification) {
        let data = notification.userInfo!["state"]
        guard let a = data else {
            print("empty data")
            return
        }
        if let time = a as? Int {
            print(time)
            DataSaver.elapsedTime += Float(time)
            elapsedTime = DataSaver.elapsedTime
        }
    }
    private func checkLastTerminal() {
        if UserDefaults.standard.bool(forKey: "terminate") {
            
            if UserDefaults.standard.bool(forKey: "play") {
                tappedStart()
            }else{
                self.elapsedTime = DataSaver.elapsedTime
                let second = Int(self.elapsedTime) % 60
                let minutes = Int(self.elapsedTime / 60) % 60
                let hours = Int(self.elapsedTime) / 3600
                
                self.minite = self.convertHourToMinite(hour: hours, minite: minutes)
                print(String(format: "%02d:%02d:%02d",hours ,minutes, second))
                self.timeLabel.text = String(format: "%02d:%02d:%02d",hours ,minutes, second)
            }
            
            DataSaver.elapsedTime += Float(UserDefaults.standard.integer(forKey: "ela"))
            elapsedTime = DataSaver.elapsedTime
            UserDefaults.standard.setValue(false, forKey: "terminate")
        }
    }
    @objc func tappedStart() {
        state = state == .stop ? .play : .stop
        startButton.setStyle(state == .stop ? .play : .pause, animated: true)
        guard state != .stop else {
            tappedStop()
            UserDefaults.standard.setValue(false, forKey: "play")
            return
        }
        UserDefaults.standard.setValue(true, forKey: "play")
        UserDefaults.standard.setValue(true, forKey: "edit")
        
        timerStart(interval: 1)
    }
    func timerStart(interval: TimeInterval,repeats:Bool = true) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { (timer) in
            self.elapsedTime += 1
            let second = Int(self.elapsedTime) % 60
            let minutes = Int(self.elapsedTime / 60) % 60
            let hours = Int(self.elapsedTime) / 3600
            
            self.minite = self.convertHourToMinite(hour: hours, minite: minutes)
            print(String(format: "%02d:%02d:%02d",hours ,minutes, second))
            self.timeLabel.text = String(format: "%02d:%02d:%02d",hours ,minutes, second)
            DataSaver.elapsedTime = self.elapsedTime
        }
    }
    @objc func tappedStop() {
        if let t = timer{
            t.invalidate()
        }
    }
    @objc func useTime() {
        self.delegate.useTime(time:Int(minite))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
