//
//  PastOrdersViewController.swift
//  foodie
//
//  Created by Raiyan Z. Jugbhery on 2021-04-09.
//

import UIKit
import Foundation

class pastOrdersTableCell: UITableViewCell{
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var customerNameLabekl: UILabel!
    @IBOutlet weak var restaurantNumberLabel: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
}

class PastOrdersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var orders = [[String]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backtoPastOrders(_ segue: UIStoryboardSegue) {
        print("and we are back")
        // Switch to the second tab (tabs are numbered 0, 1, 2)
        self.tabBarController?.selectedIndex = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let userDefaults = UserDefaults.standard
        
        if(isKeyPresentInUserDefaults(key: "PastUserOrders")) {
        // exists
            orders = userDefaults.object(forKey: "PastUserOrders") as! [[String]]
        }else {
        // doesn't exists
            UserDefaults.standard.set(orders, forKey: "PastUserOrders")
        }
        //orders = PastOrders.sharedInstance  PastUserOrders  orders = userDefaults.object(forKey: "PastUserOrders") as! [[String]]
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("OrderData"), object: nil)
        tableView.reloadData()
        tableView.allowsSelection = false
    }
    @objc func onDidReceiveData(_ notification: Notification) {
        orders = notification.userInfo!["data"] as! [[String]]
       // print(cartItems.count)
        print("data recieved")
        tableView.reloadData()
        tableView.allowsSelection = false
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
            return UserDefaults.standard.object(forKey: key) != nil
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userDefaults = UserDefaults.standard
        orders = userDefaults.object(forKey: "PastUserOrders") as! [[String]]
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? pastOrdersTableCell
        if (cell == nil) {
            cell = pastOrdersTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        let userDefaults = UserDefaults.standard
        orders = userDefaults.object(forKey: "PastUserOrders") as! [[String]]
        var reversedArray = [[String]]()
        for arrayIndex in 0...(orders.count - 1) {
            reversedArray.append(orders[(orders.count - 1)-arrayIndex])
        }
        orders = reversedArray
        if (orders.count != 0){
            let each = orders[indexPath.row]
            cell?.customerNameLabekl.text = each[0]
            cell?.restaurantNameLabel.text = each[3]
            cell?.restaurantNumberLabel.text = "Call: " + each[7] + " for pickup."
            cell?.orderTotalLabel.text = "$ " + each[4]
            cell?.orderNumberLabel.text = each[6]
            cell?.dateLabel.text = each[5]
        }
        
        return cell!
    }

}
