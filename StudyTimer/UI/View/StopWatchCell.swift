//
//  StopWatchCell.swift
//  StudyTimer
//
//  Created by Ryu on 2021/08/01.
//

import UIKit
import DynamicButton

import UIKit
import Eureka
import KYCircularProgress

//月平均もだす

public class StopWatchCell: Cell<Bool>, CellType, TimeConverter {

    let stopWatchView = StopWatchView()
    
    public override func setup() {
        super.setup()
        self.backgroundColor = .white
        
        self.addSubview(stopWatchView)
        
        stopWatchView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }
    }
    public override func update() {
        super.update()
    }
}
public final class StopWatchRow: Row<StopWatchCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        //cellProvider = CellProvider<TotalProgressCell>(nibName: "CustomCell")
    }
}
