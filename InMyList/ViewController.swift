//
//  ViewController.swift
//  InMyList
//
//  Created by Shenbagavalli Lakshmanan on 3/10/19.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import Firebase

protocol DataRefresherProtocol:class {
    func dataUpdated(isNew:Bool, listName:String)
}

class ViewController: UIViewController {
    
    var alert:UIAlertController!
    
    var tableViewLoaded: Bool = false
    
    var listName: String = ""
    
    weak var dataRefresherDelegate:DataRefresherProtocol?
    
    var displayAlert = false
    
    var shareItem:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("List name received from allLists: ",listName)
        navigationController?.navigationBar.isHidden = false
        
        //displayAlert flag will be set to True from the calling viewcontroller (AllListsHandlerWithFooter) to add item detail to new list
        if displayAlert{
            addNewItem(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        
        if self.displayAlert {
            self.navigationItem.title = "New list"
        } else {
            self.navigationItem.title = self.listName
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableViewSegue"{
            // Prepare for segue; this datarefresherdelegate will later be used for delegate to reload data
            if let tableViewController = segue.destination as? TableViewController {
                self.dataRefresherDelegate = tableViewController
                tableViewController.selectedList = self.listName
                print("table view segue")
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        topStackView.axis = axisForSize(size)
    }
    
    @IBAction func shareList(_ sender: Any) {
        print("share button chosen")
        print("ListItem count", ListItemManager.sharedList.list.count)
    
        for i in 0..<ListItemManager.sharedList.list.count{
            let eachListItem = ListItemManager.sharedList.list[i]
            shareItem += eachListItem.name
            shareItem += " "
            shareItem += String(eachListItem.quantity)
            shareItem += " "
            shareItem += eachListItem.unit
            shareItem += " "
        }
        print("Share Item", shareItem)
        let activity = UIActivityViewController(activityItems: [self.shareItem], applicationActivities: nil)
        present(activity,animated: true,completion: nil)
    }
    @IBAction func addNewItem(_ sender: Any) {
//        getItemDetails()
        print("Add new Item")
        if displayAlert{
            displayAlert = false
            self.dataRefresherDelegate?.dataUpdated(isNew: true, listName: self.listName)
        }
        else{
            self.dataRefresherDelegate?.dataUpdated(isNew: false, listName: "")
        }
    }
  
}

