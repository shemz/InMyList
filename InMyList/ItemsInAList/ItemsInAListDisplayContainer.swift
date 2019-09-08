//
//  ViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/10/19.
//  Copyright © 2019 Shenbagavalli Lakshmanan. All rights reserved.
//

import UIKit
import Firebase

protocol ToDoItemActionProtocol:class {
    func addNewItemForList(name:String)
}

class ItemsInAListDisplayContainer: UIViewController {
    
    var listName  = "New List"
    var isNewList = false
    var shareItem = ""
    
    weak var toDoActionDelegate:ToDoItemActionProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        navigationController?.navigationBar.isHidden = false
        //isNewList flag will be set to True from the calling viewcontroller (AllListsHandlerWithFooter) to add item detail to new list
        if isNewList { addNewItem(self) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = self.listName
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare for segue; this datarefresherdelegate will later be used for delegate to reload data
        if let tableViewController = segue.destination as? ItemsInAListTableViewController {
            toDoActionDelegate = tableViewController
            tableViewController.selectedListName = listName
        }
    }
    
    @IBAction func shareList(_ sender: Any) {
        
        let listModel = UserListManager.sharedUserLists.listInfoModels.first { $0.listName == listName }
        guard let itemsToShare = listModel?.prettyPrinted() else {
            return
        }
        let activity = UIActivityViewController(activityItems: [itemsToShare], applicationActivities: nil)
        present(activity,animated: true,completion: nil)
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        toDoActionDelegate?.addNewItemForList(name: listName)
    }
    
}

