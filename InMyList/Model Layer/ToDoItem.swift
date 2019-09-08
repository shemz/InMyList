//
//  ToDoItem.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 9/12/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import Foundation

struct ToDoItem: Codable {
    var name:String
    var quantity:Int
    var unit:String
    
    init(name:String,quantity:Int,unit:String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
    
    init?(listInfoJson:[String:Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: listInfoJson),
            let model = try? JSONDecoder().decode(ToDoItem.self, from: data)
        {
            self = model
        }
        else { return nil }
        
    }
    
    
    func toJson() -> [String:Any]? {
        if let jsonData = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: jsonData, options:.allowFragments) {
            return dict as? [String:Any]
        }
        return nil
    }
    
   
}
