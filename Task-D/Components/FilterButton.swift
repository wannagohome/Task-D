//
//  FilterButton.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/21.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit

class FilterButton: UIButton {
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.setTitleColor(UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 1), for: .normal)
                self.backgroundColor = .white
            } else {
                self.backgroundColor = UIColor(red: 67/255, green: 131/255, blue: 255/255, alpha: 1)
                self.setTitleColor(.white, for: .normal)
            }
        }
    }
}
