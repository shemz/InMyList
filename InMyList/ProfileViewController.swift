//
//  ProfileViewController.swift
//  InMyList
//
//  Created by vignesh ramanathan on 5/10/19.
//  Copyright © 2019 CK. All rights reserved.
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
            print("Profile picture retrieved")
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        //Signout from Firebase
        try? Auth.auth().signOut()
        
        //Signout from google
        GIDSignIn.sharedInstance()?.signOut()
        
        print("signout complete")
      //  let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SigninViewController") as! UIViewController
       // navigationController?.present(signinVC, animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
