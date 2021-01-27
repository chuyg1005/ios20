//
//  ViewController.swift
//  ShoppingHelper
//
//  Created by njuios on 2020/12/31.
//

import UIKit
import SwiftSoup

class SearchViewController: UIViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator = UIActivityIndicatorView()
    
//    var items = [Item]()
    let itemManager = ItemManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.dataSource = self
//        tableView.tableFooterView = activityIndicator
    
        tableView.backgroundView = activityIndicator
        
        showAlert()
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "提示", message: "该应用程序需要连接网络使用！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show detail" {
            if let dest = segue.destination as? WebViewViewController,
               let cell = sender as? SearchTableViewCell,
                let row = self.tableView.indexPath(for: cell)?.row {
//                print(cell.detailLink)
                dest.urlString = cell.detailLink
//                self.itemManager.visitItem(index: row)
                self.itemManager.addVisitedItem(item: itemManager.items[row])
            }
        } else if segue.identifier == "show review" {
//            print("test")
//            print((sender as? UIButton)?.superview)
            if let dest = segue.destination as? ReviewTableViewController,
                let cell = (sender as? UIButton)?.superview?.superview as? SearchTableViewCell,
                let row = self.tableView.indexPath(for: cell)?.row {
//                print(row)
                dest.reviews = Array(itemManager.items[row].reviews)
//                print(dest.reviews)
            }
        } else if segue.identifier == "show search" {
            if let dest = segue.destination as? WebViewViewController,
                let text = searchBar.text {
                let  keyword = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.capitalizedLetters)!
                dest.urlString = "https://search.bilibili.com/all?keyword=" + keyword
            }
        }
    }
    
    @IBAction func subscribe(_ sender: UIButton) {
//        let subscribe = UIImage(named: "subscribe")
//        let nonSubscribe = UIImage(named: "non-subscribe")

        if let cell = sender.superview?.superview as? SearchTableViewCell ,
           let row = self.tableView.indexPath(for: cell)?.row {
            self.itemManager.toggleItemSubscribeState(index: row)
            self.setSubscribedButtonImage(button: sender, state: self.itemManager.items[row].isSubscribed)
            self.tableView.reloadData()
        }
    }
    
    private func setSubscribedButtonImage(button: UIButton, state: Bool) {
        
        let subscribe = UIImage(named: "subscribe")
        let nonSubscribe = UIImage(named: "non-subscribe")
        button.setImage(state ? subscribe : nonSubscribe, for: .normal)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(newsList.count)
//        return items.count
        return itemManager.items.count
        //        return 14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell") as! SearchTableViewCell
//        let subscribe = UIImage(named: "subscribe")
//        let nonSubscribe = UIImage(named: "non-subscribe")
        let item = itemManager.items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.priceLabel.text = "¥" + item.price
        cell.detailLink = item.itemUrl

        item.doWithSentimentScore { score in
            DispatchQueue.main.async {
//                cell.recommandLabel.text = String(repeating: "✨", count: score)
//                cell.nameLabel.text = String(repeating: "✨", count: score)
                cell.recommandButton.setTitle(String(repeating: "✨", count: score), for: .normal)
//                print(score)
            }
        }
//        cell.subscribeButton.setImage(item.isSubscribed ? subscribe : nonSubscribe, for: .normal)
        self.setSubscribedButtonImage(button: cell.subscribeButton, state: item.isSubscribed)
        
        DispatchQueue.init(label: "image loading thread", attributes: [.concurrent]).async {
            if let url = URL(string: item.imageUrl), let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.itemImage.image = UIImage(data: data)
                }
            }
        }
        if indexPath.row == itemManager.items.count - 1 {
//            self.activityIndicator.startAnimating()
            itemManager.loadMoreItems {
//                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        return cell
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("load new data")
//    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            activityIndicator.startAnimating()
            self.itemManager.updateItems(searchContent: text) {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
