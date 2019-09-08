//
//  ListInfoModel.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 9/8/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import Foundation

struct ListInfoModel: Codable{
    var listName: String
    var dateCreated: String
    var status: String
    var items:[ToDoItem]! = []
    
    init(listName:String,dateCreated:String,status:String) {
        self.listName = listName
        self.dateCreated = dateCreated
        self.status = status
    }
    
    init?(listInfoJson:[String:Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: listInfoJson),
           let model = try? JSONDecoder().decode(ListInfoModel.self, from: data)
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
    
    func hasAnItemWith(name:String) -> Bool {
        return items.contains { $0.name.lowercased() == name.lowercased() }
    }
    
    func prettyPrinted() -> String {
        var prettyString = ""
         items.forEach { item in
            prettyString += "\(item.name) :: \(item.quantity) \(item.unit)\n"
        }
        return prettyString
    }
    

}
