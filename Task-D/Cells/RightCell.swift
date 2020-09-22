//
//  RightCell.swift
//  Task-D
//
//  Created by jinho jang on 2020/09/22.
//  Copyright © 2020 Pete. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

class RightCell: UITableViewCell {
    @IBOutlet weak var priceTitle: UILabel!
    @IBOutlet weak var roomType: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var roomImage: UIImageView!
    @IBOutlet weak var star: UIImageView!
    @IBOutlet weak var hashTags: UICollectionView!
    
    let disposeBag = DisposeBag()
    
    var room: Room? {
        didSet {
            var title: String = ""
            switch self.room?.sellingType {
            case 0: title += "월세 "
            case 1: title += "전세 "
            case 2: title += "매매 "
            default: break
            }
            
            title += self.room?.priceTitle ?? ""
            self.priceTitle.text = title
            switch self.room?.roomType {
            case 0: self.roomType.text = "원룸"
            case 1: self.roomType.text = "투쓰리룸"
            case 2: self.roomType.text = "오피스텔"
            case 3: self.roomType.text = "아파트"
            default: break
            }
            
            self.desc.text = self.room?.desc
            let url = URL(string: self.room?.imgURL ?? "")!
            self.roomImage.kf.setImage(with: url)
            
            self.hashTags.reloadData()
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "RightCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.hashTags.dataSource = self
        self.hashTags.register(HashTagCell.nib(), forCellWithReuseIdentifier: "HashTagCell")
        if let layout = hashTags.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 4
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension RightCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(3, self.room?.hashTags?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let hashTag = self.room?.hashTags?.prefix(3) else {
            return UICollectionViewCell()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCell", for: indexPath) as! HashTagCell
        cell.label.text = hashTag[indexPath.row]
        return cell
    }
}
