//
//  CalendarCell.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/09/26.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    @IBOutlet weak var calenderLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }


}
