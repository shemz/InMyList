//
//  GoogleSignInHandler.swift
//  
//
//  Created by shenbagavalli lakshmanan on 8/27/19.
//

import Foundation
import GoogleSignIn
import Firebase


class GoogleSignInHandler:NSObject, GIDSignInDelegate {
    
    var userEmail: String = ""
    var userID: String = ""
    var onSuccessfulLogin:(()->Void)? = nil
    
    //Should display error to user...
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            return
        }
        else{
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        signInToFirebase(using:credential) {
            self.updateSharedUserInfo(user: user)
            self.onSuccessfulLogin?()
        }
    }
    
    func signInToFirebase(using credential:AuthCredential, onSuccess: @escaping ()->Void) {
        Auth.auth().signInAndRetrieveData(with: credential, completion: {(AuthResultCallback, error) in
            if error != nil{
                return
            }
            onSuccess()
        })
    }
    
    func updateSharedUserInfo(user:GIDGoogleUser) {
        //Get User Email and remove the substring "@gmail.com" from email; then replace '.' with ','
        self.userEmail = user.profile.email
        let userName = self.userEmail.replacingOccurrences(of: "@gmail.com", with: "")
        self.userID = userName.replacingOccurrences(of: ".", with: ",")
        UserIDManager.sharedUserDetail.userID = self.userID
        
        //Get user image,first name and last name from 'user'
        UserIDManager.sharedUserDetail.userGivenName = user.profile.givenName
        UserIDManager.sharedUserDetail.userFamilyName = user.profile.familyName
        if user.profile.hasImage {
            UserIDManager.sharedUserDetail.profilePicture = user.profile.imageURL(withDimension: 120)
        }
    }
    
}


