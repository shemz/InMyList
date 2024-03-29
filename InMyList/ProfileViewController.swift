//
//  ProfileViewController.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 5/10/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = self.profilePicture.frame.height/2
        profilePicture.layer.masksToBounds = true
        
        userName.text = UserIDManager.sharedUserDetail.userGivenName + " " + UserIDManager.sharedUserDetail.userFamilyName
        
        if  let url = UserIDManager.sharedUserDetail.profilePicture,
            let data = try? Data(contentsOf: url)
        {
            profilePicture.image = UIImage(data: data)
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        //Signout from Firebase
        try? Auth.auth().signOut()
        
        //Signout from google
        GIDSignIn.sharedInstance()?.signOut()
    
        navigationController?.popToRootViewController(animated: true)
    }

}
