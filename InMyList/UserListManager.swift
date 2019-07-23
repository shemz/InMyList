//
//  UserListManager.swift
//  InMyList
//
//  Created by vignesh ramanathan on 5/14/19.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation

class UserListManager{
    static var sharedUserLists = UserListManager()
    private init (){}
    
    var listNames:[ListNames] = []
}

