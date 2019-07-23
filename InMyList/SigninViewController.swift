//
//  SigninViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/17/19.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SigninViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        customSignIn.layer.cornerRadius = 10
        customSignIn.clipsToBounds = true
        customSignIn.layer.borderWidth = 3
        customSignIn.layer.borderColor = UIColor.white.cgColor
        
        //Signin silently
        GIDSignIn.sharedInstance()?.signIn()
        
    }
    
//    @IBOutlet weak var signIn: GIDSignInButton!
  
    @IBOutlet weak var customSignIn: UIButton!
    
    @IBAction func googleSignIn(_ sender: Any) {
            print("Signin called from here")
            GIDSignIn.sharedInstance()?.signIn()
    }
}
