//
//  UserIDManager.swift
//  InMyList
//
//  Created by vignesh ramanathan on 5/6/19.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation

class UserIDManager{
    static var sharedUserDetail = UserIDManager()
    private init (){}
    
    var userID: String = ""
    var userGivenName: String = ""
    var userFamilyName: String = ""
    
    var profilePicture: URL?
}

