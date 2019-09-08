//
//  UserListManager.swift
//  InMyList
//
//  Created by shenbagavalli lakshmanan on 5/14/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import Foundation
import Firebase

typealias ActionCompletedBlock = ()->Void
typealias ToDoItemsFetchCompletedBlock = ([ToDoItem])->Void


class UserListManager{
    static var sharedUserLists = UserListManager()
    private init (){}
    
    private var allListsRefDB:DatabaseReference {
        //This returns userLists, which contains all the list names of a particular user
        let userListsRef = Database.database().reference(withPath: "userLists")
        let currentUserListsRef = userListsRef.child(UserIDManager.sharedUserDetail.userID)
        return currentUserListsRef.child("allListsOfUser")
    }
    
    private var allUserItemsListRefDB:DatabaseReference {
        //This will return userListItems, which contains the items in each list
        let userListItemsRefDB = Database.database().reference(withPath: "userListItems")
        return userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID)
    }
    
    var listInfoModels:[ListInfoModel] = []
    
    //MARK:- List operations
    func hasAListWith(name:String) -> Bool {
        return listInfoModels.contains { $0.listName.lowercased() == name.lowercased() }
    }
    
    func isItemDuplicate(item:ToDoItem, inListWithName listName:String) -> Bool {
        let listInfoModel = listInfoModels.first { $0.listName == listName }
        return listInfoModel?.hasAnItemWith(name: item.name) == true
    }
    
    func observerDataFromDB(onFetchComplete:ActionCompletedBlock?) {
        //Observe that reference for data changes
        allListsRefDB.observe(.value, with: {DataSnapshot in
            self.listInfoModels.removeAll()
            for child in DataSnapshot.children{
                if let snapshotFromDB = (child as? DataSnapshot)?.value as? [String : Any],
                    let listInfoModel = ListInfoModel(listInfoJson: snapshotFromDB)
                {
                    self.listInfoModels.append(listInfoModel)
                }
            }
            onFetchComplete?()
        })
    }
    
    func addANewList(_ listInfoModel:ListInfoModel) {
        let newListRefDB = allListsRefDB.child(listInfoModel.listName)
        newListRefDB.setValue(listInfoModel.toJson())
    }
    
    func removeListFromDBWith(name: String){
        allListsRefDB.child(name).removeValue()
        allUserItemsListRefDB.child(name).removeValue()
    }
    
    func update(items:[ToDoItem], ofListWithName listName:String) {
        //listInfoModel
        let  listInfoModelIndex = listInfoModels.firstIndex{ $0.listName == listName }
        guard let index =  listInfoModelIndex else { return }
        var newListInfoModel = listInfoModels[index]
        newListInfoModel.items = items
        listInfoModels[index] = newListInfoModel
    }

}

//MARK:- To do item operations
extension UserListManager {
    func observeItemsIn(selectedListName:String, onFetchComplete:ActionCompletedBlock?) {
        //create reference to the specific list
        let selectedListDBRef = allUserItemsListRefDB.child(selectedListName)
        
        //Listen to the data changes in the database
        selectedListDBRef.observe(.value, with: { [weak self] DataSnapshot in
            var toDoItemsFromDB:[ToDoItem] = []
            //Read the items from the table and add them to listFromDB array; this will then be used to populate the shared list
            for child in DataSnapshot.children{
                if let snapshotFromDB = (child as? DataSnapshot)?.value as? [String : Any],
                    let todoItem = ToDoItem(listInfoJson: snapshotFromDB) {
                    toDoItemsFromDB.append(todoItem)
                }
            }
            self?.update(items: toDoItemsFromDB, ofListWithName: selectedListName)
            onFetchComplete?()
        })
        
    }
    
    func addANew(item:ToDoItem, inListWithName selectedListName:String) {
        let selectedListRef = allUserItemsListRefDB.child(selectedListName)
        let newItemRef = selectedListRef.child(item.name)
        newItemRef.setValue(item.toJson())
    }
    
    func removeItem(item:ToDoItem, fromListWithName selectedListName:String) {
        allUserItemsListRefDB.child(selectedListName).child(item.name).removeValue()
    }
}

