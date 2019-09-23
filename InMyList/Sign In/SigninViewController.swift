//
//  SigninViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/17/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SigninViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var customSignIn: UIButton!
    
    var googleSignInHandler:GoogleSignInHandler!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleSignInHandler = GoogleSignInHandler(segueTo: { [weak self] in
            self?.performSegue(withIdentifier: "showListsWithFooter", sender: self)
        })
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = googleSignInHandler
        customSignIn.layer.cornerRadius = 10
        customSignIn.clipsToBounds = true
        customSignIn.layer.borderWidth = 3
        customSignIn.layer.borderColor = UIColor.white.cgColor
        
        //Signin silently
        GIDSignIn.sharedInstance()?.signIn()
     
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}
