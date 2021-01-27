//
//  HistoryTableViewController.swift
//  ShoppingHelper
//
//  Created by shiba on 2021/1/11.
//  Copyright © 2021 shiba. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    let itemManager = ItemManager.shared
    
    var items: [Item] {
        Array(itemManager.visitedItems)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyTableViewCell") as! HistoryTableViewCell
        //        let subscribe = UIImage(named: "subscribe")
        //        let nonSubscribe = UIImage(named: "non-subscribe")
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.detailLink = item.itemUrl
        
        // Configure the cell...
        item.doWithCurrentPrice { currentPrice in
            //            if let currentPrice = currentPrice {
            //
            //            }
            guard let price = Double(item.price), let currentPrice = currentPrice else {
                DispatchQueue.main.async {
                    cell.priceLabel.text = "¥" + item.price
                }
                return
            }
            DispatchQueue.main.async {
                cell.priceLabel.text = "¥" + String(currentPrice)
            }
            //                    let diff = currentPrice - price
            //        //            print("currentPrice = \(currentPrice), historyPrice = \(price)")
            //                    if diff == 0 {
            //                        DispatchQueue.main.async {
            //                            cell.priceLabel.textColor = UIColor.black
            //                            cell.priceLabel.text = "¥" + item.price
            //                        }
            //                    } else if diff > 0 {
            //                        DispatchQueue.main.async {
            //                            cell.priceLabel.textColor = UIColor.red
            //                            cell.priceLabel.text = "¥" + String(currentPrice)
            //                        }
            //
            //                    } else {
            //                        DispatchQueue.main.async {
            //                            cell.priceLabel.textColor = UIColor.green
            //                            cell.priceLabel.text = "¥" + String(currentPrice)
            //                        }
            //                    }
        }
        DispatchQueue.init(label: "image loading thread", attributes: [.concurrent]).async {
            if let url = URL(string: item.imageUrl), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.itemImage.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == "show detail" {
                    if let dest = segue.destination as? WebViewViewController,
                       let cell = sender as? HistoryTableViewCell,
                           let row = self.tableView.indexPath(for: cell)?.row{
        //                print(cell.detailLink)
                        dest.urlString = cell.detailLink
    //                    self.itemManager.visitItem(index: row)
                        self.itemManager.addVisitedItem(item: items[row])
                    }
                }
            }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
