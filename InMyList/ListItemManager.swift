//
//  ListItemManager.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/12/19.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct ItemList{
    var name:String
    var quantity:Int
    var unit:String
}

class ListItemManager{
    static var sharedList = ListItemManager()
    private init (){}
  
    var list:[ItemList] = []
 /*
    var newItem = ["name": "plums",
                   "quantity": "5",
                   "unit": "count"] as [String : Any]
   */
    
    //addLIstItem function is no longer needed since the list details are directly fetched from the DB
    /*
    func addListItem() {
        list.append(ItemList(name: "milk",quantity: 1, unit: "count"))
//        list.append(ItemList(name: "rice",quantity: 2, unit: "count"))
//        list.append(ItemList(name: "apples",quantity: 2, unit: "count"))
        
//        let listRefDB = Database.database().reference(withPath: "list-items")
//        let itemRefDB = listRefDB.child("plums")
        
//        itemRefDB.setValue(newItem)
//        print(newItem," added")
    }
 */
 
}
