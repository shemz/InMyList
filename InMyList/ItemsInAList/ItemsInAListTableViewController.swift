//
//  TableViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/11/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase

class ItemsInAListTableViewController: UITableViewController {
    var selectedListName:String!
    var alert:UIAlertController!
    var duplicateAlert:UIAlertController!
    
    private var selectedListInfoModel:ListInfoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        UserListManager.sharedUserLists.observerDataFromDB (onFetchComplete: nil)
        UserListManager.sharedUserLists.observeItemsIn(selectedListName: selectedListName) { [weak self] in
            self?.selectedListInfoModel = UserListManager.sharedUserLists.listInfoModels.first {
                $0.listName == self?.selectedListName
            }
            self?.tableView.reloadData()
        }
        
    }
    
    //Format today's date to the format required for the DB
    func today(format: String = "dd-mm-yyyy") -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    
    func getNewItem(){
        alert = UIAlertController(title: "New Item", message: "Enter Item Details", preferredStyle: .alert)
        addInputFields(for: nil)
        alert.addAction(addAction())
        alert.addAction(cancelAction())
        present(alert, animated: true, completion: nil)
    }
    
    func editItem(item:ToDoItem) {
        alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        addInputFields(for: item)
        alert.addAction(editAction(origItem: item))
        alert.addAction(cancelAction())
        present(alert, animated: true, completion: nil)
    }
    
    func generateAlertForDuplicates(){
        duplicateAlert = UIAlertController(title: "Duplicate Item", message: "Item already exists in the list!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in})
        duplicateAlert.addAction(okAction)
        self.present(duplicateAlert, animated: true, completion: nil)
    }
}

//MARK:- TableView handling
extension ItemsInAListTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedListInfoModel?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? ToDoItemCell,
            let toDoItem = selectedListInfoModel?.items[indexPath.row]
            else {
                return  UITableViewCell()
        }
        
        cell.itemName.text = toDoItem.name
        cell.itemQuantity.text = String(toDoItem.quantity)
        cell.itemUnit.text = toDoItem.unit
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Add a swipe button for edit, call editItemDetails with the indexpath of the row being edited
        let editAction = UITableViewRowAction(style: .normal, title: "edit",handler: { [weak self] (rowAction, indexPath) in
            guard let toDoItem = self?.selectedListInfoModel?.items[indexPath.row]
                else { return }
            self?.editItem(item: toDoItem)
        })
        editAction.backgroundColor = UIColor.blue
        
        
        //Add a swipe button for delete, call deleteitemdetails with the indexpath of the row being deleted
        let deleteAction = UITableViewRowAction(style: .default, title: "delete",handler: { [weak self] (rowAction, indexPath) in
            guard
                let listName = self?.selectedListName,
                let toDoItem = self?.selectedListInfoModel?.items[indexPath.row]
                else { return }
            UserListManager.sharedUserLists.removeItem(item: toDoItem, fromListWithName: listName)
        })
        return [editAction,deleteAction]
    }
    
}

//MARK:- Input handling
extension ItemsInAListTableViewController {
    
    func addInputFields(for item:ToDoItem?) {
        alert.addTextField(configurationHandler: { textField in
            textField.text = item?.name
            textField.placeholder = "Enter item here"
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.textColor = UIColor.blue
            textField.autocorrectionType = .yes
            textField.returnKeyType = .next
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = item != nil ? String(item?.quantity ?? 0) : nil
            textField.placeholder = "Enter quanity here"
            textField.keyboardType = .numberPad
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.textColor = UIColor.blue
            textField.returnKeyType = .next
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.text = item?.unit
            textField.placeholder = "Enter lb/oz/count here"
            textField.textColor = UIColor.blue
            textField.font = UIFont(name: "ChalkboardSE-Regular", size: 18.0)
            textField.returnKeyType = .done
        })
    }
    
    func addAction() -> UIAlertAction {
        
        let addAction =  UIAlertAction(title: "Add", style: .default) { [weak self] (action) in
            guard
                let strongSelf = self,
                let newToDoItem = strongSelf.toDoItemFromAlert() else { return }
            
            let isListNew = !UserListManager.sharedUserLists.hasAListWith(name: strongSelf.selectedListName)
            
            if (isListNew) {
                let listInfoModel = ListInfoModel(listName: strongSelf.selectedListName, dateCreated: strongSelf.today(), status: "open")
                UserListManager.sharedUserLists.addANewList(listInfoModel)
                UserListManager.sharedUserLists.addANew(item: newToDoItem, inListWithName: strongSelf.selectedListName)
            }
            else {
                if UserListManager.sharedUserLists.isItemDuplicate(item: newToDoItem, inListWithName: strongSelf.selectedListName) {
                    strongSelf.generateAlertForDuplicates()
                }
                else {
                    UserListManager.sharedUserLists.addANew(item: newToDoItem, inListWithName: strongSelf.selectedListName)
                    
                }
            }
        }
        
        return addAction
    }
    
    func editAction(origItem:ToDoItem) -> UIAlertAction {
        
        let editAction =  UIAlertAction(title: "Edit", style: .default) { [weak self] (action) in
            guard
                let strongSelf = self,
                let newToDoItem = strongSelf.toDoItemFromAlert() else { return }
            
            UserListManager.sharedUserLists.removeItem(item: origItem, fromListWithName: strongSelf.selectedListName)
            
            UserListManager.sharedUserLists.addANew(item: newToDoItem, inListWithName: strongSelf.selectedListName)
            
        }
        
        return editAction
    }
    
    func cancelAction() -> UIAlertAction {
        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            guard
                let strongSelf = self
                else { return }
            let isListNew = !UserListManager.sharedUserLists.hasAListWith(name: strongSelf.selectedListName)
            if (isListNew) {
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
        return cancelAction
    }
    
    
    func toDoItemFromAlert() -> ToDoItem? {
        guard let name = alert.textFields?[0].text,
            let quantity = Int(alert.textFields?[1].text ?? "0"),
            let unit = alert.textFields?[2].text
            else {
                return nil
        }
        return  ToDoItem(name: name, quantity: quantity, unit: unit)
    }
}

//MARK:- Container Delegate Actions
extension ItemsInAListTableViewController: ToDoItemActionProtocol {
    func addNewItemForList(name:String) {
        selectedListName = name
        getNewItem()
    }
}

