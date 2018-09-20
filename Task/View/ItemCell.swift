//
//  personCell.swift
//  Task
//
//  Created by Admin on 9/15/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setData(item: Item){
        //        print(item)
        DispatchQueue.main.async {
            
            if let title = item.title{
                self.nameLabel.text = title
            }
            
            if let descrip = item.descrip {
                self.descriptionLabel.text = descrip
            }
            
            if let imageUrl = item.imageUrl{
                self.profileImageView.loadImageUsingCacheWithURLString(imageUrl, placeHolder: #imageLiteral(resourceName: "Imageplaceholder"))
            }
            
            if item.imageUrl == ""{
                self.profileImageView.image = #imageLiteral(resourceName: "Imageplaceholder")
            }
        }
    }
}
