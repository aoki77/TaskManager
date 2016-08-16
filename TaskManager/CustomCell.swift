//
//  CustomCell.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/15.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var time: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell")
        // Labelを生成.
        time = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height))
        time?.text = "aaa"
        time?.backgroundColor = UIColor.redColor()
        time?.textAlignment = NSTextAlignment.Center
        
        // Cellに追加.
        self.contentView.addSubview(time!)
    }
}