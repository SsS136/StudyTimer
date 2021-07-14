//
//  ViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit
import FanMenu
import Macaw
import SnapKit
import KYCircularProgress

class StudyPageViewController: UIViewController {
    enum Mode {
        case remaining
        case current
    }
    let bottomButton = FanMenu(frame: CGRect(center: CGPoint(x: UX.width/2, y: UX.height - UX.bottomMargin), size: CGSize(width: UX.bottomSize, height: UX.bottomSize)))
    let segment = UISegmentedControl(items: ["残り","現在"]).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.selectedSegmentIndex = 0
    }
    let studyCollection = StudyCollectionViewController().then {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let bottomTitle = ["New","Calender","Edit"]


    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        view.backgroundColor = .dynamicDark
        // Do any additional setup after loading the view.
        self.testSaveData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {[self] in
            setupSegment()
            setupCollectionViewController()
            setupBottomButton()
        }
    }
    #if DEBUG
    private func testSaveData() {
        //DataSaver.SaveSubjectsData([Subject(title: "国語", baseTime: 1000, currentTime: 405),Subject(title: "英語", baseTime: 10000, currentTime: 5800),Subject(title: "数学", baseTime: 100000, currentTime: 40005),Subject(title: "理科", baseTime: 34456, currentTime: 5800),Subject(title: "社会", baseTime: 1000, currentTime: 405)])
//            UserDefaults.standard.register(defaults: ["Entire" : try! PropertyListEncoder().encode(Entire(DataSaver.subjects))])
        UserDefaults.standard.register(defaults: ["Subjects" : []])
        DataSaver.SaveEntireData(Entire(entireBaseTime: 0, entireCurrentTime: 0))
        DataSaver.SaveMonthData(Month.shared)
    }
    #endif
    private func setupBottomButton() {
        bottomButton.button = FanMenuButton(id: "normal", image: UIImage(systemName: "text.book.closed"), color: Color(val: 0x7C93FE))
        bottomButton.items = [
            FanMenuButton(id: bottomTitle[0], image: UIImage(systemName: "plus"), color: .coral),
            FanMenuButton(id: bottomTitle[1], image: UIImage(systemName: "calendar"), color: .firebrick),
            FanMenuButton(id: bottomTitle[2], image: UIImage(systemName: "pencil"), color:.darkKhaki)
        ]
        bottomButton.backgroundColor = .clear
        bottomButton.menuRadius = 80
        bottomButton.interval = (Double.pi, 2 * Double.pi)
        bottomButton.onItemDidClick = {
            if $0.id == self.bottomTitle[0] {//New
                let new = NewSubjectController()
                new.delegate = self
                let nav = UINavigationController(rootViewController: new)
                self.present(nav, animated: true, completion: nil)
            }else if $0.id == self.bottomTitle[1] {//Calender
                
            }else{//Edit
                
            }
        }
        self.view.addSubview(bottomButton)
    }
    private func setupSegment() {
        segment.addTarget(self, action: #selector(segmentSelected(_:)), for: .valueChanged)
        self.view.addSubview(segment)
        segment.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalTo(view)
            $0.width.equalTo(150)
        }
    }
    private func setupCollectionViewController() {
        self.addChild(studyCollection)
        self.view.addSubview(studyCollection.view)
        studyCollection.didMove(toParent: self)
        studyCollection.view.snp.makeConstraints {
            $0.top.equalTo(segment.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    @objc func segmentSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            studyCollection.mode = .remaining
        }else{
            studyCollection.mode = .current
        }
    }
}

extension StudyPageViewController : NewSubjectControllerDelegate {
    func reloadCollectionView() {
        studyCollection.mode = studyCollection.mode
    }
}
