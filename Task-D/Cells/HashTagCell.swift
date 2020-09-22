//
//  HashTagCell.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit

class HashTagCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
