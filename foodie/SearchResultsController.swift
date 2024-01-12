import UIKit
import FittedSheets

class DragTableCell:UITableViewCell{
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var restaurantImage: CustomImageView!
}


class SearchResultsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    public var restaurants = [Restaurant]()
    var selectedRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: Notification.Name("didReceiveData"), object: nil)
        tableView.reloadData()
    }

    // Observer which listens to changes supplied by "didReceiveData"
    @objc func onDidReceiveData(_ notification: Notification) {
        restaurants.removeAll()
        restaurants = notification.userInfo!["data"] as! [Restaurant]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? DragTableCell
        if (cell == nil) {
            cell = DragTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        cell!.isUserInteractionEnabled = true
         // Tap Gesture recognizes selected rows
         let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))

        // Tag field saves selected row to allow respective data to be passed to other VC later
        cell!.addGestureRecognizer(tap)
        cell!.tag = indexPath.row
        if !(restaurants.isEmpty){
            let restaurant = self.restaurants[indexPath.row]
            cell?.restaurantName.text = restaurant.name
            cell?.restaurantAddress.text = restaurant.location.address
            cell?.restaurantCategory?.text = getCategoriesFromRestaurant(restaurant: restaurant)
            if let url = URL(string: restaurant.logo.url!) {
                cell?.restaurantImage.loadImage(from: url)
                //cell?.restaurantImage.loadImage(from: url)
                cell?.restaurantImage.layer.cornerRadius = 10
                cell?.restaurantImage.clipsToBounds = true
                
           }
        }
//
//        let restaurant = self.filteredRestaurants[indexPath.row]
//
//
//
//        // Verify that URL in object is valid URL
//        if let url = URL(string: restaurant.logo.url) {
//            cell?.cellImageView.loadImage(from: url)
//            cell?.cellImageView.layer.cornerRadius = 10
//            cell?.cellImageView.clipsToBounds = true
//        }
        
        return cell!
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Lets prepare function know which row was selected
        selectedRow = sender.view!.tag
        performSegue(withIdentifier: "SearchResultToFoodVC", sender: self)

    }
    
    // MARK: Segue Helper Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Pass restaurant data to another view controller
        if segue.destination is FoodTableViewController {
            let vc = segue.destination as? FoodTableViewController
            vc?.restaurant = self.restaurants[selectedRow!]
        }
    }
    
    static func setupCard(from parent: UIViewController, in view: UIView?) {
        
        let useInlineMode = view != nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate Search View Controller Manually -> Allows Fitted sheets to render multiple views on screen
        let controller = storyboard.instantiateViewController(withIdentifier: "searchResultsVC")
        let sheet = SheetViewController(
            controller: controller,
            sizes: [.fixed(150), .percent(0.5), .marginFromTop(100)],
            options: SheetOptions(useInlineMode: useInlineMode))
        sheet.allowPullingPastMaxHeight = false
        sheet.allowPullingPastMinHeight = false
        
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = false
        sheet.overlayColor = UIColor.clear
        
        sheet.contentViewController.view.layer.shadowColor = UIColor.black.cgColor
        sheet.contentViewController.view.layer.shadowOpacity = 0.1
        sheet.contentViewController.view.layer.shadowRadius = 10
        sheet.allowGestureThroughOverlay = true
        
        addSheetEventLogging(to: sheet)
        
        if let view = view {
            sheet.animateIn(to: view, in: parent)
        } else {
            parent.present(sheet, animated: true, completion: nil)
        }
    }
    
    static func addSheetEventLogging(to sheet: SheetViewController) {
        let previousDidDismiss = sheet.didDismiss
        sheet.didDismiss = {
            print("did dismiss")
            previousDidDismiss?($0)
        }
        
        let previousShouldDismiss = sheet.shouldDismiss
        sheet.shouldDismiss = {
            print("should dismiss")
            return previousShouldDismiss?($0) ?? true
        }
        
        let previousSizeChanged = sheet.sizeChanged
        sheet.sizeChanged = { sheet, size, height in
            print("Changed to \(size) with a height of \(height)")
            previousSizeChanged?(sheet, size, height)
        }
        

    }
    func getCategoriesFromRestaurant(restaurant: Restaurant) -> String {
        var categories = [String]()
        
        for category in restaurant.menus[0].food_categories{
            categories.append(category.name)
        }
        
        return categories.joined(separator: ", ")
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
