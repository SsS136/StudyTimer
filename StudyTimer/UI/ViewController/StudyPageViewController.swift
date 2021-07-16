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
        UserDefaults.standard.register(defaults: ["Subjects" : [],"Entire" : try! PropertyListEncoder().encode(Entire(entireBaseTime: 0, entireCurrentTime: 0)),"Month" : try! PropertyListEncoder().encode(Month.shared),"dayStudy" : [],"AtLastStudy" : try! JSONEncoder().encode(Date())])
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
                self.presentNavigationController(root: new)
            }else if $0.id == self.bottomTitle[1] {//Calender
                self.presentNavigationController(root: DateViewController())
            }else if $0.id == self.bottomTitle[2] {//Edit
                let edit = EditViewController()
                edit.delegate = self
                self.presentNavigationController(root: edit)
            }
        }
        self.view.addSubview(bottomButton)
    }
    private func presentNavigationController<T:UIViewController>(root:T,completion:(() -> Void)? = nil) {
        let nav = UINavigationController(rootViewController: root)
        self.present(nav, animated: true, completion: completion)
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

extension StudyPageViewController : NewSubjectControllerDelegate, EditViewControllerDelegate {
    func reloadCollectionView() {
        studyCollection.mode = studyCollection.mode
    }
}

