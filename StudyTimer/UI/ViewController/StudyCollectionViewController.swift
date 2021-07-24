//
//  StudyCollectionViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit

class StudyCollectionViewController : UIViewController {
    
    var subjects:[Subject] {
        return DataSaver.subjects ?? []
    }
    var entire:Entire {
        return DataSaver.entire
    }
    private var combine:[Any] {
        var arr:[Any] = subjects
        arr.append(entire as Any)
        return arr
    }
    
    var collectionView:UICollectionView!
    
    var mode:StudyPageViewController.Mode = .remaining {
        didSet{
            UIView.animate(withDuration: 0.1, animations: {
                self.collectionView.alpha = 0
            },completion: {_ in
                self.collectionView.removeFromSuperview()
                self.setupCollectionView()
                self.collectionView.alpha = 0
                UIView.animate(withDuration: 0.1, animations: {
                    self.collectionView.alpha = 1
                })
            })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamicDark
        setupCollectionView()
    }
    private func setupCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .dynamicDark
        collectionView.register(StudyCollectionCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
    func removeAllCell() {
        for i in 0..<combine.count {
            if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) {
                cell.removeFromSuperview()
            }
        }
    }
    private func presentNavigationController<T:UIViewController>(root:T,completion:(() -> Void)? = nil) {
        let nav = UINavigationController(rootViewController: root)
        self.present(nav, animated: true, completion: completion)
    }
}
extension StudyCollectionViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.bounds.width - 40, height: UX.firstCellHeight)
        }else{
            return CGSize(width: view.bounds.width - 40, height: UX.generalCellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return combine.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! StudyCollectionCell
        if indexPath.row == 0 {
            cell.setupFirstCell(entire, mode: mode)
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 4
            cell.isBlanked = false
        }else if indexPath.row == combine.count{
            cell.setupBlank()
            cell.isBlanked = true
        }else{
            let gesture = StudyTimerLongPress(target: self, action:#selector(deleteRow(_:)))
            gesture.at = indexPath
            cell.addGestureRecognizer(gesture)
            cell.setupCell(subjects[indexPath.row - 1], mode: mode)
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 4
            cell.isBlanked = false
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UX.lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 9, left: 3, bottom: 9, right: 3)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? StudyCollectionCell, !cell.isBlanked else { return }
        if indexPath.row == 0 {
            presentNavigationController(root: TotalViewController())
            return
        }
        let sub = SubjectDetailViewController()
        sub.delegate = self
        sub.subjectTitle = subjects[indexPath.row - 1].title
        presentNavigationController(root: sub)
    }
}

extension StudyCollectionViewController : TimeConverter {
    @objc private func deleteRow(_ sender:StudyTimerLongPress) {
        switch sender.state {
        case .began:
            let alert = UIAlertController(title: nil, message: "この勉強記録を削除しますか？", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let action = UIAlertAction(title: "はい", style: .destructive) { _ in
                if let sub = self.subjects[safe:sender.at.row - 1] {
                    DataSaver.dayStudy[sub.title] = nil
                    DataSaver.subjects.remove(at: sender.at.row - 1)
                    self.monthDataSetter()
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: [sender.at])
                        self.collectionView.reloadSections(IndexSet(integer: 0))
                    }, completion: nil)
                }else{
                    fatalError("Error")
                }
            }
            alert.addAction(cancel)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension StudyCollectionViewController : SubjectDetailViewControllerDelegate {
    func reloadCollectionView() {
        let mode = self.mode
        self.mode = mode
    }
}

class StudyTimerLongPress : UILongPressGestureRecognizer {
    var at:IndexPath!
}
extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
