//
//  TaskPop.swift
//  TaskManager
//
//  Created by 青木孝乃輔 on 2016/08/17.
//  Copyright © 2016年 青木孝乃輔. All rights reserved.
//

import UIKit

class TaskPop: UIViewController {
    @IBOutlet weak var popTitle: UILabel!
    @IBOutlet weak var popTime: UILabel!
    @IBOutlet weak var popDetail: UILabel!
    @IBOutlet weak var popTitleContent: UILabel!
    @IBOutlet weak var popTimeContent: UILabel!
    @IBOutlet weak var popDetailContent: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.whiteColor()
        let mainRect = UIScreen.mainScreen().bounds
        self.view.layer.frame = CGRectMake(0, 0, mainRect.width, mainRect.height/5)
        let rect = self.view.bounds
        let allHeight = rect.height
        let allWidth = rect.width
        let titleWidth = allWidth / 12
        let titleHeight = allHeight / 10
        let titleLabel: UILabel = UILabel(frame: CGRectMake(titleWidth, titleHeight, 100, 50))
        titleLabel.text = "タイトル"
        self.view.addSubview(titleLabel)


        
    }

}

