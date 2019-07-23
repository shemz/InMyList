//
//  TableViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/11/19.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import Firebase
/*
struct ItemList{
    var name:String
    var quantity:Int
    var unit:String
}
 */

class TableViewController: UITableViewController {
    var list:[ItemList] = []
    var alert:UIAlertController!
    var duplicateAlert:UIAlertController!
    var isEditAlert: Bool = false
    var alertItemNameLabel: String = ""
    var alertItemQuantityLabel: String = ""
    var alertItemUnitLabel: String = ""
    var editArrayIndex: Int = 0
    var selectedList: String = ""
    var newDBItem:ItemList = ItemList(name:"",quantity:0,unit:"")
    var isNewList = false
    var newListName:String = ""
    var newListStatus:String = "open"
    var itemCount = 0
    var duplicateItemFound: Bool = false
    
    //Create connection to the database, to the path "list-items"
//    let listRefDB = Database.database().reference(withPath: "list-items")
    let userListItemsRefDB = Database.database().reference(withPath: "userListItems")
    
    //Create reference to userLists Database, which will store list name, date of creation and status
    let listDetailsRefDB = Database.database().reference(withPath: "userLists")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        remove this now to connect to db
        readAllUserListsFromDB()
//        -- not required anymore; the program has been updated to read data directly from the table
//        ListItemManager.sharedList.addListItem()
//        print("Before reload data")
//        self.tableView.reloadData()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListItemManager.sharedList.list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? CustomTableViewCell
        let tableItem = ListItemManager.sharedList.list[indexPath.row]
        
        cell?.itemName.text = tableItem.name
        cell?.itemQuantity.text = String(tableItem.quantity)
        cell?.itemUnit.text = tableItem.unit

        return cell ?? UITableViewCell()
    }
    /*Could not use this override once edit button was added in swipe action; so a separate delete button was also added
    // editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the shared list array
            ListItemManager.sharedList.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            print("Array after delete",ListItemManager.sharedList.list)
        }
    }*/
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Add a swipe button for edit, call editItemDetails with the indexpath of the row being edited
        let editAction = UITableViewRowAction(style: .normal, title: "edit",handler: { (rowAction, indexPath) in
            print("edit Button tapped. Row item value ")
            self.editItemDetails(editRowIndexPath: indexPath as NSIndexPath)
        })
        editAction.backgroundColor = UIColor.blue
        
        
        //Add a swipe button for delete, call deleteitemdetails with the indexpath of the row being deleted
        let deleteAction = UITableViewRowAction(style: .default, title: "delete",handler: { (rowAction, indexPath) in
            print("delete Button tapped. Row item value ")
            self.deleteItemDetails(deleteRowIndexPath: indexPath as NSIndexPath)
        })
        return [editAction,deleteAction]
    }
    
    //edit specific row from the tableview
    func editItemDetails(editRowIndexPath: NSIndexPath){
        self.isEditAlert = true
        
        //get the item details of the row selected for edit
        let cell = tableView(self.tableView!, cellForRowAt: editRowIndexPath as IndexPath) as? CustomTableViewCell
        alertItemNameLabel = (cell?.itemName.text)!
        alertItemQuantityLabel = (cell?.itemQuantity.text)!
        alertItemUnitLabel = (cell?.itemUnit.text)!
        
        print("Details to send to alert at edit", alertItemNameLabel, alertItemQuantityLabel, alertItemUnitLabel)
        
        editArrayIndex = editRowIndexPath.row
        print("editArrayIndex: ",editArrayIndex)
        
        //Create alert to edit item details
        getItemDetails()
    }
    
    //delete specific row from the tableview
    func deleteItemDetails(deleteRowIndexPath: NSIndexPath){
        print("Delete action at",deleteRowIndexPath.row)
        
        //remove item from database
        let removeItem = ListItemManager.sharedList.list[deleteRowIndexPath.row]
        userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID).child(selectedList).child(removeItem.name).removeValue()
        
        //Calling readRecordsFromDB will update shared list and tableview
        readAllUserListsFromDB()
        
        /*
        //remove item from shared item list
        ListItemManager.sharedList.list.remove(at: deleteRowIndexPath.row)
        //remove item from tableview
        tableView.deleteRows(at: [deleteRowIndexPath as IndexPath], with: .fade)
 */
        print("Array after delete",ListItemManager.sharedList.list)
    }
    
    //Create Alert for adding new item and editing existing item
    func getItemDetails(){
        alert = UIAlertController(title: "New Item", message: "Enter item details ", preferredStyle: .alert)
        
        //Add textfields to alert
        alert.addTextField(configurationHandler: { textField in
            if self.isEditAlert{
                textField.text = self.alertItemNameLabel
            }
            else{
                textField.placeholder = "Enter item here"
            }
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.textColor = UIColor.blue
        })
        
        alert.addTextField(configurationHandler: { textField in
            if self.isEditAlert{
                textField.text = self.alertItemQuantityLabel
            }
            else{
                textField.placeholder = "Enter quanity here"
            }
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.textColor = UIColor.blue
        })
        
        alert.addTextField(configurationHandler: { textField in
            if self.isEditAlert{
                textField.text = self.alertItemUnitLabel
            }
            else{
                textField.placeholder = "Enter lb/oz/count here"
            }
            textField.textColor = UIColor.blue
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            
        })
        
        //Add new item to shared list item array, if it is a new item; if an existing item is edited, update the specific item in shared list item array
        var alertTitle = ""
        if self.isEditAlert{
            alertTitle = "Edit"
            let editItemAction = UIAlertAction(title: alertTitle, style: .default, handler: { (action) -> Void in
                
                guard let name = self.alert.textFields?[0].text,
                    let quantity = Int(self.alert.textFields?[1].text ?? "0"),
                    let unit = self.alert.textFields?[2].text
                    else {
                        return
                }

                //remove the old item from the database
                let removeItem = ListItemManager.sharedList.list[self.editArrayIndex]
//                self.userListItemsRefDB.child(removeItem.name).removeValue()
                self.userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID).child(self.selectedList).child(removeItem.name).removeValue()
                
                //pass the values from the alert text fields read above to the DBitem variable which will be used to add record to the database
                self.newDBItem.name = name
                self.newDBItem.quantity = quantity
                self.newDBItem.unit = unit

                print("before DB")
                print(self.newDBItem)
                self.writeListItemDetailsToDB()

                //Reload the table view from the database
                self.readAllUserListsFromDB()
            })
            alert.addAction(editItemAction)
            
        }else{
            alertTitle = "Add"
            let addItemAction = UIAlertAction(title: alertTitle, style: .default, handler: { (action) -> Void in
                
                guard let name = self.alert.textFields?[0].text,
                    let quantity = Int(self.alert.textFields?[1].text ?? "0"),
                    let unit = self.alert.textFields?[2].text
                    else {
                        return
                }
                //                ListItemManager.sharedList.list.append(ItemList(name: name,quantity: quantity,unit: unit)) - no longer needed; read records from DB will update this
        //        print(ListItemManager.sharedList.list)
                
                //pass the values from the alert text fields read above to the DBitem variable which will be used to add record to the database
                self.newDBItem.name = name
                self.newDBItem.quantity = quantity
                self.newDBItem.unit = unit
                
                //Call writeListNameToDB to insert new record into database
                print(self.newDBItem)
                
                if self.isNewList{
                    self.isNewList = false
                    //write new list name to userLists table
                    self.writeUserListDetailsToDB()
                }
                self.writeListItemDetailsToDB()
                
                //Read new records from table and update tableview
                self.readAllUserListsFromDB()
//                self.tableView.reloadData()
            })
            alert.addAction(addItemAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
            //When cancel button is pressed, allLists screen should be displayed, if it is not in edit action and if it is a new list and no items have been added in new list
            if self.isNewList && self.isEditAlert == false && self.itemCount == 0 {
                print("view popped")
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            })
        
        alert.addAction(cancelAction)
        self.present(alert,animated: true)
        
        //Set editalert to false, so if user presses + button, the alert has default placeholders
        self.isEditAlert = false
        
    }
    
    func writeUserListDetailsToDB(){
        //Insert new record in to the userLists table
        print("writing list details to DB")
  
        let userListRefDB = listDetailsRefDB.child(UserIDManager.sharedUserDetail.userID)
        let allListsOfUserRefDB = userListRefDB.child("allListsOfUser")
        let newListRefDB = allListsOfUserRefDB.child(self.newListName)
        let newListDetail = ["dateCreated": self.today(format: "dd-mm-yyyy"),
                             "listName": self.newListName,
                             "status": self.newListStatus] as [String : Any]
        
        newListRefDB.setValue(newListDetail)
        print("new list detail added")
    }
    
    func writeListItemDetailsToDB(){
        print("writing to DB")

        //In the database, userlists contains list
//        let itemRefDB = userListRefDB.child(self.newDBItem.name as String!)
        let userRefDB = userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID)
        let listRefDB = userRefDB.child(selectedList)
        let itemRefDB = listRefDB.child(self.newDBItem.name)
        
        let insertItemDB = ["name": newDBItem.name,
                            "quantity": newDBItem.quantity,
                            "unit": newDBItem.unit] as [String : Any]
        
        //Verify for item duplicate
        let maxListitems = ListItemManager.sharedList.list.count
        for i in 0..<maxListitems {
            let listItem = ListItemManager.sharedList.list[i]
            print("listItem: ",listItem)
            if newDBItem.name.lowercased() == listItem.name.lowercased(){
                self.duplicateItemFound = true
                break
            }
        }
        if self.duplicateItemFound{
            print("Duplicate record found")
            duplicateItemFound = false
            self.generateAlertForDuplicates(type: "duplicateItem")
        }
        else{
            
            //Keeps track of items added to the list. This will help decide if the current view should be cancelled when pressing cancel button in add alert
            self.itemCount += 1
            
            itemRefDB.setValue(insertItemDB)
            print("new record added to DB")
        }
        
    }
    
    func readAllUserListsFromDB(){
        var items:ItemList = ItemList(name: "", quantity: 0, unit: "")
        var listFromDB:[ItemList] = []
        print("listFromDB:", listFromDB)
        var newListItems:[ItemList] = []
        
        //create a reference to the specific user
        let userRefDB = userListItemsRefDB.child(UserIDManager.sharedUserDetail.userID)
        
        //create reference to the specific list
        let listRefDB = userRefDB.child(self.selectedList)
        
        //Listen to the data changes in the database
        listRefDB.observe(.value, with: {DataSnapshot in
            print("Observe table data", DataSnapshot.value as Any)
            
            //Read the items from the table and add them to listFromDB array; this will then be used to populate the shared list
            for child in DataSnapshot.children{
                if let snapshot = child as? DataSnapshot{
                    let snapshotFromDB = snapshot.value as? [String : Any]
                    items.name = snapshotFromDB?["name"] as! String
                    items.quantity = snapshotFromDB?["quantity"] as! Int
                    items.unit = snapshotFromDB?["unit"] as! String
                    print("items ",items)
                    
                    listFromDB.append(items)
                  //  print("snapshot value ",snapshot.value)
                }
            }
            
            //Populate the shared list with the new data from the table
            ListItemManager.sharedList.list = listFromDB
            print("shared list ", ListItemManager.sharedList.list)
            
            //Reload the tableview to reflect the new data
            self.tableView.reloadData()
            
        })
    }
        
        //This function reads the list of items from a specific list
    func readListItemsFromDB(){
        var items:ItemList = ItemList(name: "", quantity: 0, unit: "")
        var listFromDB:[ItemList] = []
        //Listen to the data changes in the database
        userListItemsRefDB.observe(.value, with: {DataSnapshot in
            print("Observe table data", DataSnapshot.value as Any)
            
            //Read the items from the table and add them to listFromDB array; this will then be used to populate the shared list
            for child in DataSnapshot.children{
                if let snapshot = child as? DataSnapshot{
                    let snapshotFromDB = snapshot.value as? [String : Any]
                    items.name = snapshotFromDB?["name"] as! String
                    items.quantity = snapshotFromDB?["quantity"] as! Int
                    items.unit = snapshotFromDB?["unit"] as! String
                    print("items ",items)
                    listFromDB.append(items)
                }
            }
                
            //Populate the shared list with the new data from the table
            ListItemManager.sharedList.list = listFromDB
            print("shared list ", ListItemManager.sharedList.list)
            
            //Reload the tableview to reflect the new data
            self.tableView.reloadData()
                
        })
    }
    
    func generateAlertForDuplicates(type: String){
        duplicateAlert = UIAlertController(title: "Duplicate Item", message: "Item already exists in the list!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
        duplicateAlert.addAction(okAction)
        self.present(duplicateAlert, animated: true, completion: nil)
        print("duplicate alert created")
    }
    
    //Format today's date to the format required for the DB
    func today(format: String = "dd-mm-yyyy") -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

extension TableViewController: DataRefresherProtocol {
    func dataUpdated(isNew: Bool, listName: String) {
        if isNew{
            self.isNewList = isNew
            self.newListName = listName
            print("New Listname:",self.newListName)
            self.getItemDetails()
        }
        else{
            self.isNewList = isNew
            self.getItemDetails()
        }
    }
    
}

