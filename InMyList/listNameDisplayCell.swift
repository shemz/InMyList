//
//  listNameDisplayCell.swift
//  
//
//  Created by vignesh ramanathan on 3/31/19.
//

import UIKit

class listNameDisplayCell: UICollectionViewCell {
    
    @IBOutlet weak var listNameDisplayLabel: UILabel!
    
    @IBOutlet weak var tickImage: UIImageView!
    
    //Observe the isSelected property of collection view cell to select and unselect a list
    override var isSelected: Bool {
        didSet{
            if self.isSelected{
                print("Selected list: ", self.listNameDisplayLabel)
                if self.tickImage.isHidden {
                    self.tickImage.isHidden = false
                }
                else{
                    self.tickImage.isHidden = true
                }
                
            }
            else{
                print("DeSelected: ",self.listNameDisplayLabel)
                self.tickImage.isHidden = true
            }
        }
    }
    
    @IBAction func displayUserDetails(_ sender: UIButton) {
        print("user details")
    }
}
