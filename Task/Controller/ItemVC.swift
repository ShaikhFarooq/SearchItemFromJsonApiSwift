//
//  ItemVC.swift
//  Task
//
//  Created by Admin on 9/15/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import CoreData

class ItemVC: UIViewController {
    
    private let itemCellID = "itemCell"
    private let emptyCellID = "emptyCell"
    
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray = [Item]()
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpTableView()
        configureSearchController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setUpTableView(){
        self.mTableView.tableFooterView = UIView()
        mTableView.delegate = self
        mTableView.dataSource = self
    }
    
    private  func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchBar.delegate = self
        self.searchBar.backgroundImage = UIImage()
        
        for subView in searchBar.subviews
        {
            subView.layer.cornerRadius = 20
            for subView1 in subView.subviews
            {
                
                if subView1.isKind(of: UITextField.self)
                {
                    (subView1 as? UITextField)?.textColor = UIColor(displayP3Red: 0/255, green: 61/255, blue: 77/255, alpha: 1.0)
                    (subView1 as? UITextField)?.borderStyle = .roundedRect
                    subView1.backgroundColor = .white
                }
            }
        }
    }
    
    private func reloadData(){
        DispatchQueue.main.async(execute: {
            self.mTableView.reloadData()
        })
    }
    
    
    private func saveInCoreDataWith(dictionary: [String: AnyObject])  {
        
        if let itemEntity = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as? Item {
            itemEntity.title = dictionary["title"] as? String
            let description = dictionary["description"] as? [String]
            itemEntity.descrip = description?.first
            itemEntity.imageUrl = dictionary["imageUrl"] as? String
            do {
                
                try context.save()
                
            } catch let error {
                print(error)
            }
        }
    }
    
    private func fetchData(searchText: String){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "SELF.title.stringValue BEGINSWITH[c] %@", searchText)
        do{
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if results.count > 0{
                itemArray = results as! [Item]
                mTableView.reloadData()
            }else{
                itemArray.removeAll()
                print("No items found")
                let service = APIService()
                service.query = searchText
                service.getDataWith { (result) in
                    switch result {
                    case .Success(let itemArray):
                        //  print(items)
                        for item in itemArray{
                            let itemDic = item
                            //  print(itemDic)
                            // self.clearData()
                            self.saveInCoreDataWith(dictionary: itemDic)
                            self.fetchData(searchText: searchText)
                            self.mTableView.reloadData()
                        }
                        
                    case .Error(let message):
                        DispatchQueue.main.async {
                            showAlert(targetVC: self, title: "Error", message: message)
                        }
                    }
                }
                mTableView.reloadData()
            }
            
        }catch{
            print("Error : \(error)")
        }
    }
    
    private func clearData() {
        do {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Item.self))
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("ERROR DELETING : \(error)")
            }
        }
    }
}

extension ItemVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults && itemArray.count > 0 {
            self.mTableView.separatorStyle = .singleLine
            return itemArray.count
        }else{
            self.mTableView.separatorStyle = .none
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if shouldShowSearchResults &&  itemArray.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: itemCellID, for: indexPath) as! ItemCell
            let item = itemArray[indexPath.row]
            print(item)
            cell.setData(item: item)
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as! EmptyCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldShowSearchResults && itemArray.count > 0{
            return 80
        }else{
            return mTableView.frame.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if itemArray.count > 0{
            guard var personTitle = itemArray[indexPath.row].title else{return}
            personTitle = personTitle.removeWhitespace()
            let urlString = detailWebUrl+personTitle
            let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ItemDetailVC") as? ItemDetailVC
            vc?.urlString = urlString
            vc?.personTitle = personTitle
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

extension ItemVC:  UISearchBarDelegate, UISearchDisplayDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        closeKeyboard()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == false{
            shouldShowSearchResults = true
        }else{
            shouldShowSearchResults = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty == true{
            shouldShowSearchResults = false
            closeKeyboard()
            removeAllData()
            
        }else{
            
            shouldShowSearchResults = true
            fetchData(searchText: searchText)
        }
    }
    
    private  func closeKeyboard(){
        searchBar.perform(#selector(self.resignFirstResponder), with: nil, afterDelay: 0.1)
    }
    
    func removeAllData(){
        itemArray.removeAll()
        scrollTableviewToTop()
        reloadData()
    }
    
    private  func scrollTableviewToTop(){
        if itemArray.count == 0{
            mTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
}


