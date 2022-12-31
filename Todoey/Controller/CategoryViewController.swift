

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()  //Instance of realm database.
    var categories: Results<Category>?  //array of categories of type Results
    
   override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
       tableView.rowHeight = 70.0
 }
   
    
//MARK: TableView DATASource Methods //Table view looks for following methods when its loads.
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] { // we should handle optional like this.
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.colorOfCell)
        } else {
            cell.textLabel?.text = "No Category Added Yet"
        }
    
        return cell
    }
    
    
// MARK: TableView Delegate Method "didSelectRowAt"
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
// MARK: Add-Button Press methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text ?? ""
            newCategory.colorOfCell = UIColor.randomFlat().hexValue()
            self.saveCategory(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Category"
            textField = alertTextField
            
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
//MARK: Data Manipulation Methods
    func saveCategory(category: Category) {
        
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("error in saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategory(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToDelete = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryToDelete)
                }
            } catch {
                print("error in deleting:", error)
            }
        }
    }
}



