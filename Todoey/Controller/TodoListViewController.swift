//let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist") // data will store here and in item.plist file
import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var items: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            print("selected category is :", selectedCategory!)
            loadItems()
        }
    }
    
    
   override func viewDidLoad() {
//        let dataPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print(dataPath)
        super.viewDidLoad()
       tableView.rowHeight = 65.0
    }
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        if let colourHex = selectedCategory?.colorOfCell {
            guard let navbar = navigationController?.navigationBar else { print(fatalError("error h kuch"))}
            
            if let navBarColour = UIColor(hexString: colourHex) {
                
                //navbar.barTintColor = navBarColour
                navbar.backgroundColor = ContrastColorOf(navBarColour, returnFlat: true)
                //navbar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
                searchBar.tintColor = navBarColour
            }
            
        }
            
    }
    
//MARK: TableView DATASource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1 // no. of rows in tableView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategory!.colorOfCell)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
            
            
            cell.accessoryType =   item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No item Added"
        }
      
        return cell
    }
// MARK: TableView Delegate Method "didSelectRowAt"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = item.done ? false : true// toggle the done property to true of false
                }
            } catch {
                print(error)
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
// MARK: Add-Button Press methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        
        // what will happen user clicks on our UIAlert
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.timeStamp = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving data: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add New Task"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

//MARK: Data Manipulation Methods
    
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
     }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("error in deleting:", error)
            }
        }
    }
    
}

//MARK: UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "timeStamp", ascending: true)
        tableView.reloadData()

    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { // if there is no text in searchbar
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // cursor will not blink now
            }
        }
    }
}
   




