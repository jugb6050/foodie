//
//  CartViewController.swift
//  foodie
//
//  Created by Raiyan Z. Jugbhery on 2021-04-09.
//

import UIKit

class CartTableCell:UITableViewCell{
    @IBOutlet weak var cartImageViewer: UIImageView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var foodQuantLabel: UILabel!
    @IBOutlet weak var foodPriceLabel: UILabel!
    
}

class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var hstLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var cartItems = Cart.sharedInstance
    
    @IBAction func backFromModal(_ segue: UIStoryboardSegue) {
        print("and we are back")
        // Switch to the second tab (tabs are numbered 0, 1, 2)
        self.tabBarController?.selectedIndex = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        cartItems = Cart.sharedInstance
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("cartData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCartClear(_:)), name: Notification.Name("cartCleared"), object: nil)
        tableView.reloadData()
        subtotalLabel.text = "$ " + String(format: "%.2f", Cart.getCartSubTotal())
        hstLabel.text = "$ " + String(format: "%.2f", Cart.calculateTax())
        totalLabel.text = "$ " + String(format: "%.2f", Cart.calculateTotal())
        self.checkoutButton.isHidden = false

        // Do any additional setup after loading the view.
    }
    @IBAction func clearButtonPressed(_ sender: Any) {
        Cart.clearCart()
        let cartDict:[String:[CartItem]] = ["data": Cart.sharedInstance]
        
        // Push Notification to All Observers
        NotificationCenter.default.post(name: Notification.Name("cartCleared"), object: nil, userInfo: cartDict)
        print("cart cleared")
    }
    @objc func onCartClear(_ notification: Notification) {
        cartItems = notification.userInfo!["data"] as! [CartItem]
       // print(cartItems.count)
        print("data recieved")
        tableView.reloadData()
        subtotalLabel.text = "$ " + "0.00"
        hstLabel.text = "$ " + "0.00"
        totalLabel.text = "$ " + "0.00"
        
    }
    @objc func onDidReceiveData(_ notification: Notification) {
        cartItems = notification.userInfo!["data"] as! [CartItem]
       // print(cartItems.count)
        print("data recieved")
        tableView.reloadData()
        subtotalLabel.text = "$ " + String(format: "%.2f", Cart.getCartSubTotal())
        hstLabel.text = "$ " + String(format: "%.2f", Cart.calculateTax())
        totalLabel.text = "$ " + String(format: "%.2f", Cart.calculateTotal())
    }
    
    func tableView(_ TableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cartItems.count)
        return cartItems.count
        
    }
    
    func tableView(_ TableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? CartTableCell
        if (cell == nil) {
            cell = CartTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        cell?.foodLabel.numberOfLines = 0
        cell?.foodLabel.lineBreakMode = .byWordWrapping
        cell?.foodLabel.sizeToFit()
        cell!.isUserInteractionEnabled = true
        if (cartItems.count != 0){
            let item = cartItems[indexPath.row]
            cell?.foodLabel.text = item.getItem().name
            cell?.foodQuantLabel.text = String(item.getQuantity()) + "x"
            cell?.foodPriceLabel.text = "$ " + (String(item.getItem().price))
            cell?.cartImageViewer.image = item.getImage()
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let itemindex = indexPath.row
            Cart.removeItem(index: itemindex)
            let someDict:[String:[CartItem]] = ["data": Cart.sharedInstance]
            // Push Notification to All Observers
            NotificationCenter.default.post(name: Notification.Name("cartData"), object: nil, userInfo: someDict)
            print("data pushed")
            tableView.reloadData()
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
