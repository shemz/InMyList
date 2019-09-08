//
//  UserIDManager.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 5/6/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
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

