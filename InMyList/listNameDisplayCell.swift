//
//  listNameDisplayCell.swift
//  
//
//  Created by shenbagavalli lakshmanan on 3/31/19.
//

import UIKit

class ListNameDisplayCell: UICollectionViewCell {
    
    @IBOutlet weak var listNameDisplayLabel: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    
    override func awakeFromNib() {
        listNameDisplayLabel.layer.cornerRadius = 10
        listNameDisplayLabel.clipsToBounds = true
        backgroundColor = UIColor.clear
        listNameDisplayLabel.numberOfLines = 0
        listNameDisplayLabel.layer.borderColor = UIColor.gray.cgColor
        listNameDisplayLabel.layer.borderWidth = 3
    }
    
    override var isSelected: Bool {
        didSet {
            self.tickImage.isHidden = !self.isSelected
        }
    }
    
    @IBAction func displayUserDetails(_ sender: UIButton) {
    }
}
