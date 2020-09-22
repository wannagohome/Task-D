//
//  Average.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit

class AverageCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    var average: Average? {
        didSet {
            self.title.text = self.average?.name
            self.year.text = self.average?.yearPrice
            self.month.text = self.average?.monthPrice
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "AverageCell", bundle:nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
