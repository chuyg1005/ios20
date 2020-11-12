//
//  ShoppingItemTableViewController.swift
//  ShoppingTracker
//
//  Created by shiba on 2020/11/12.
//  Copyright © 2020 shiba. All rights reserved.
//

import UIKit

class ShoppingItemTableViewController: UITableViewController {
    
    var shoppingItems = [ShoppingItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedShoppingItems = loadShoppingItems() {
            shoppingItems += savedShoppingItems
        } else {
            loadSampleData()
        }
        // 增加编辑选项
        navigationItem.leftBarButtonItem = editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shoppingItems.count
    }

    private func loadSampleData() {
        let photo1 = UIImage(named: "item1")
        let photo2 = UIImage(named: "item2")
        
        guard let item1 = ShoppingItem(name: "商品1", image: photo1, desc: "非常好") else {
            fatalError("miss error while creating item1")
        }
        
        guard let item2 = ShoppingItem(name: "商品2", image: photo2, desc: "特别好") else {
            fatalError("miss error while creating item2")
        }
        
        shoppingItems += [item1, item2]
        
    }
    
    @IBAction func unwindToShoppingItemList(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? ShoppingItemViewController, let item = sourceViewController.shoppingItem{
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                shoppingItems[selectedIndexPath.row] = item
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: shoppingItems.count, section: 0)
                shoppingItems.append(item)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            saveShoppingItems()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ShoppingItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ShoppingItemTableViewCell else {
            fatalError("cell casted error")
        }

        // Configure the cell...
        let item = shoppingItems[indexPath.row]

        cell.nameLabel.text = item.name
        cell.photoImageView.image = item.image
        cell.descLabel.text = item.desc
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //MARK: 总是留在最后再更新视图，否则会存在问题
            shoppingItems.remove(at: indexPath.row)
            saveShoppingItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
    
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            guard let detailController = segue.destination as? ShoppingItemViewController else {
                fatalError("this segue is not towards shoppingItemViewController")
            }
            
            guard let selectCell = sender as? ShoppingItemTableViewCell else {
                fatalError("sender is not a table cell")
            }
            
            guard let indexPath = tableView.indexPath(for: selectCell) else {
                fatalError("not found the cell in table view")
            }
            
            let selectShoppingItem = shoppingItems[indexPath.row]
            detailController.shoppingItem = selectShoppingItem
        default:
            print("segue from tableViewController to another controller")
        }
    }
    
    private func saveShoppingItems() {
        NSKeyedArchiver.archiveRootObject(shoppingItems, toFile: ShoppingItem.archiveURL.path)
    }
    
    private func loadShoppingItems()->[ShoppingItem]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ShoppingItem.archiveURL.path) as? [ShoppingItem]
    }
}
