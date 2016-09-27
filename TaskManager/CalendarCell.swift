//
//  CalendarCell.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/09/26.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

final class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var calenderLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    // MARK: - プライベート関数
    private func setupLabel() {
        calenderLabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
        calenderLabel.font = UIFont(name: "HiraKakuProN-W3", size: 12)
        calenderLabel.textAlignment = NSTextAlignment.Center
    }

}
