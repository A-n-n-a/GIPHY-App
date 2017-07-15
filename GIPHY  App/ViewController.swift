

import UIKit
import Firebase
import FirebaseDatabase
import CoreData
import SystemConfiguration


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
//    var isSearching = false
    
    var gifStrings = [String]()
    
    var gifsViewsFromCoreData = [UIImageView]()

    
    var selectedRow = CollectionViewCell()
    
    var ref: DatabaseReference?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var context = NSManagedObjectContext()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        context = appDelegate.persistentContainer.viewContext
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        myCollectionView.collectionViewLayout = layout
        
        
        retrieveDataFromFirebase()
        
        if isConnectedToNetwork() == false {
            gifsViewsFromCoreData = fetchFromCoreData()
            myCollectionView.reloadData()
            print("FROM CORE DATA: \(gifsViewsFromCoreData.count)")
            
        }
        
        //deleteDataInCoreData()


        
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if gifStrings.count == 0 {
            self.myCollectionView.reloadData()
        }
        print("NUMBER OF ROWS: \(gifStrings.count)")
        
        var count = Int()
        
        if isConnectedToNetwork() == false {
            count = gifsViewsFromCoreData.count
        } else {
            count = gifStrings.count
        }
        
        
        return count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if isConnectedToNetwork() == false {
            let gifView = gifsViewsFromCoreData[indexPath.row]
            cell.gifImage = gifView
            cell.addSubview(gifView)
        } else {
        
            DispatchQueue.global().async {
                let urlString = self.gifStrings[indexPath.row]
                let gifImage = UIImage.gif(url: urlString)
                let gifView = UIImageView(image: gifImage)
                
                DispatchQueue.main.async {
                    cell.addSubview(gifView)
                    cell.gifImage = gifView
                }
            }
        }
        
        
        saveDataToFirebase(text: gifStrings)
        
        return cell
    }
    
    // PARSE DATA
    
    func parseData(url: URL) -> [String] {
        
        var gifsArray = [String]()
        
        do {
            
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            let mainDictionary = json["data"] as! [[String : Any]]

            var n = 1
            for i in mainDictionary {
                
                
                let images = i["images"] as! [String : Any]
                let appropriateSize = images["fixed_height_small"] as! [String : Any]
                let gifStringUrl = appropriateSize["url"] as! String
                gifsArray.append(gifStringUrl)
                
                print(n)
                n += 1
                
            }
        }
        catch {
            print(error)
        }
        return gifsArray
    }
    
    // GET DATA
    
    func getData() -> [String] {
        
        var result = [String]()
        

        let input = searchBar.text!
        let inputAddingPercentEncoding = input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        
        let searchUrl = URL(string: "http://api.giphy.com/v1/gifs/search?q=\(inputAddingPercentEncoding!)&api_key=c61e8bb1a9c14a6e8dc6fb15d211b4b5")
        result = parseData(url: searchUrl!)

        return result
    }
    
    
    //MARK: FIREBASE
    
    func saveDataToFirebase(text: [String]) {
        
        ref?.child("gifList").setValue(text)
        
    }
    
    func retrieveDataFromFirebase() {
        
        ref?.queryOrdered(byChild: "gifList").observe(.childAdded, with: { (snapshot) in
           
            let item = snapshot.value! as! [String]
            print("ITEM COUNT: \(item.count)")
            var index = 0
            for _ in 1...item.count {
                let url = item[index]
                self.gifStrings.append(url)
                index += 1

            }

            if self.gifStrings.count == (item.count) {
                self.myCollectionView.reloadData()
                
            }
            
        })
    }
    
    
    // MARK: CORE DATA
    
    // save data to Core Data
    func saveToCoreData(array: [String]) {
        
        var imageViewArray = [UIImageView]()
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Gif", into: self.context)
        //entity.setValue(array, forKey: "arrayOfStringUrls")
        
        for i in array {
            let imageView = stringToView(string: i)
            imageViewArray.append(imageView)
        }
        entity.setValue(imageViewArray, forKey: "arrayOfStringUrls")
        
        do {
            try context.save()
            print("SAVED")
            
        } catch {
            print("ERROR: \(error)")
        }

    }
    
    // getting data from core data
    
    
    func fetchFromCoreData() -> [UIImageView] {
        
        var imageViewArray = [UIImageView]()
        //var gifs = [String]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gif")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results {
            
                    
                    // fetch data
                    if let gifImageViewArray = (result as AnyObject).value(forKey: "arrayOfStringUrls") as? [UIImageView] {
                        
                         imageViewArray = gifImageViewArray
                        
                    }
                    
                }
                
            }
        } catch {
            print("Error: \(error)")
        }
        return imageViewArray
    }
    
    func deleteDataInCoreData() {
        
        var gifs = [String]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gif")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results {

                    
                    let resultData = result as! NSManagedObject
                    context.delete(resultData)
                    try context.save()
                    print("DELETED")
                    
               
                }
                
            }
        } catch {
            print("Error: \(error)")
        }
    
    }

    
    
    //MARK: CORE DATA
//    func save(name: String) {
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//
//        let context = appDelegate.persistentContainer.viewContext
//
//        // Creating Managed Objects
//
//        let recipe = NSEntityDescription.insertNewObject(forEntityName: "Recipe", into: context) //as! RecipeMO
//        
//        // Set value to attribute
//        recipe.setValue("", forKey: "title")
//        
//        // 4
//        do {
//            try context.save()
//            testArray.append(recipe)
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }

    //MARK: SEARCH BAR
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if  searchBar.text == "" {
//            isSearching = false
            view.endEditing(true)
            retrieveDataFromFirebase()
            self.myCollectionView.reloadData()
            
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text == nil || searchBar.text == "" {

            view.endEditing(true)
        } else {

            gifStrings = getData()
            myCollectionView.reloadData()
            //print("SEARCH COUNT: \(gifStrings.count)")
            saveToCoreData(array: gifStrings)

        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let destViewController = segue.destination as! LargeGifViewController
        
        let selectedRowIndex = self.myCollectionView.indexPath(for: sender as! CollectionViewCell)
        selectedRow = self.myCollectionView.cellForItem(at: selectedRowIndex!) as! CollectionViewCell
        
        destViewController.stringGif = gifStrings[(selectedRowIndex?.row)!]
    }
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
    
    func stringToView(string: String) -> UIImageView {
        //let urlString = self.gifStrings[indexPath.row]
        let gifImage = UIImage.gif(url: string)
        let gifView = UIImageView(image: gifImage)
        
        return gifView
    }


}

