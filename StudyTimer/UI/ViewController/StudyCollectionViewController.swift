//
//  StudyCollectionViewController.swift
//  StudyTimer
//
//  Created by Ryu on 2021/07/13.
//

import UIKit

class StudyCollectionViewController : UIViewController {
    
    lazy var subjects = DataSaver.subjects ?? []
    lazy var entire = DataSaver.entire
    
    private lazy var combine:[Any] = {
        var arr:[Any] = subjects 
        arr.append(entire as Any)
        return arr
    }()
    

    let collectionView:UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .dynamicDark
        collectionView.register(StudyCollectionCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        return collectionView
    }()
    
    var mode:StudyPageViewController.Mode = .remaining {
        didSet{
            self.collectionView.performBatchUpdates({
                self.collectionView.reloadSections(IndexSet(integer: 0))
                //self.collectionView.reloadData()
            }, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamicDark
        setupCollectionView()
    }
    private func setupCollectionView() {
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
}
extension StudyCollectionViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: view.bounds.width - 40, height: 180)
        }else{
            return CGSize(width: view.bounds.width - 40, height: 65)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return combine.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! StudyCollectionCell
        if indexPath.row == 0 {
            print(entire)
            cell.setupFirstCell(entire ?? Entire(entireBaseTime: 0, entireCurrentTime: 0), mode: mode)
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 4
        }else{
            print(subjects[indexPath.row - 1])
            cell.setupCell(subjects[indexPath.row - 1], mode: mode)
            cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            cell.layer.shadowColor = UIColor.darkGray.cgColor
            cell.layer.shadowOpacity = 0.4
            cell.layer.shadowRadius = 4
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 18
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
}
