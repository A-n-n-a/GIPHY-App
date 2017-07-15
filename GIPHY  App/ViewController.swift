

import UIKit
import Firebase
import FirebaseDatabase


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    var gifStrings = [String]()
    var gifsArray = [UIImageView]()
    
    //var gifImage = UIImage()
    var gifView = UIImageView()
    
    var image = UIImage()
    
    //var url = String()
    
    var ref: DatabaseReference?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
//        let topConstraint = NSLayoutConstraint(item: myCollectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 100)
//        view.addConstraints([topConstraint])
        
        
//        //MARK: RETRIEVE DATA FROM FIREBASE
//        let currentUserID = Auth.auth().currentUser?.uid
//        
//        ref?.child(usersStr).child(currentUserID!).observe(.childAdded, with: { (snapshot) in
//            //ref?.child(citiesStr).observe(.childAdded, with: { (snapshot) in
//            if let value = snapshot.value as? String {
//                self.item = value
//                self.cities.append(self.item)
//                self.id = snapshot.key
//                self.idArray.append(self.id)
//                self.tableView.reloadData()
//            }
//        })

        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        myCollectionView.collectionViewLayout = layout
        
        
        
        ref?.queryOrdered(byChild: "gifList").observe(.childAdded, with: { (snapshot) in
            // ref?.child("gifList").observe(.childAdded, with: { (snapshot) in
            
            
            
            let item = snapshot.value! as! [String]
            //print(item)
            var index = 0
            for _ in 0...24 {
                let url = item[index]
                self.gifStrings.append(url)
                //print(url)
                index += 1
                //print(result.count)
                
                
                //                    result.append(item[String(index)] as! String)
                //                    index += 1
            }
            print(self.gifStrings.count)
            if self.gifStrings.count == 25 {
                self.myCollectionView.reloadData()
                //  return
            }
            //                //self.gifStrings = item
            //                //let singleRecipe = Recipe(dictionary: self.item)
            //                //self.recipesSearchFromFirebase.append(singleRecipe)
            //
            
            
        })

        
        
        //retrieveDataFromFirebase()
        //myCollectionView.reloadData()
       // print(gifStrings.count)
        
    
        //gifStrings = getData()
        //myCollectionView.reloadData()
        
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(gifStrings.count)
        if gifStrings.count == 0 {
            self.myCollectionView.reloadData()
        }
        return gifStrings.count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        DispatchQueue.global().async {
            let urlString = self.gifStrings[indexPath.row]
            let gifImage = UIImage.gif(url: urlString)
            let gifView = UIImageView(image: gifImage)
            
            DispatchQueue.main.async {
                cell.addSubview(gifView)
                cell.gifImage = gifView
            }
        }
        
        
                        //print(gifImage!)
        
        //let gifView = gifsArray[indexPath.row]
        
//        print(gifStrings.count)
//        if gifStrings.count == 0 {
//            self.myCollectionView.reloadData()
//        }
        
        //cell.gifImage.center.x = cell.frame.size.width/(CGFloat(2.0))
        
        
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
            //let gif = json["data"][0]["images"][1]["fixed_height_small"].string // as! [[String:AnyObject]]
            
            //removeDataFromFirebase(isSearching: isSearching)
            
            for i in mainDictionary {
                
                
                let images = i["images"] as! [String : Any]
                let appropriateSize = images["fixed_height_small"] as! [String : Any]
                let gifStringUrl = appropriateSize["url"] as! String
                
//                let gifImage = UIImage.gif(url: gifStringUrl)
//                gifView = UIImageView(image: gifImage)
//               
//                print(gifImage!)
                
                gifsArray.append(gifStringUrl)
                //myCollectionView.reloadData()

                

                //let singleRecipe = Recipe(dictionary: i)
                
                //recipeArray.append(singleRecipe)
                
//                let recipesItem = [
//                    titleString: singleRecipe.title,
//                    hrefString: singleRecipe.href,
//                    ingredientsString: singleRecipe.ingredients,
//                    thumbnailString: singleRecipe.recipeImage ?? " "
//                    ] as [String : Any]
//                
//                saveDataToFirebase(text: recipesItem, isSearching: isSearching)
                
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
        
        if isSearching {
            if searchBar.text != nil || searchBar.text != "" {
                let input = searchBar.text!
                let inputAddingPercentEncoding = input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
                
                let searchUrl = URL(string: "http://api.giphy.com/v1/gifs/search?q=\(inputAddingPercentEncoding!)&api_key=c61e8bb1a9c14a6e8dc6fb15d211b4b5")
                result = parseData(url: searchUrl!)
                
                
//                        let itemSize = UIScreen.main.bounds.width/3 - 3
//                        let layout = UICollectionViewFlowLayout()
//                        layout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0)
//                        layout.itemSize = CGSize(width: itemSize, height: itemSize)
//                
//                        layout.minimumInteritemSpacing = 3
//                        layout.minimumLineSpacing = 3
//                        
//                        myCollectionView.collectionViewLayout = layout
            }
        } else {
            
            let gifStringURL : String = "https://media1.giphy.com/media/JIX9t2j0ZTN9S/100.gif"
//            let gifImage = UIImage.gif(url: gifStringURL)!
//            gifView = UIImageView(image: gifImage)
//           
//            print(gifImage)
            result.append(gifStringURL)
            
            
            
//            let defaultUrl = URL(string: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
//            defaultRecipes = parseData(url: defaultUrl!)
        }
        
        return result
    }
    
    // RETRIEVE DATA
    
//    func retrieveDataFromFirebase(isSearching: Bool) {
//
//        if isSearching {
//            
//            ref?.child(searchString).observe(.childAdded, with: { (snapshot) in
//                
//                self.item = snapshot.value! as! [String : AnyObject]
//                let singleRecipe = Recipe(dictionary: self.item)
//                self.recipesSearchFromFirebase.append(singleRecipe)
//                
//                if self.recipesSearchFromFirebase.count == 10 {
//                    self.tableView.reloadData()
//                    //  return
//                }
//                
//            })
//        } else {
//            
//            ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
//                
//                self.item = snapshot.value! as! [String : AnyObject]
//                let singleRecipe = Recipe(dictionary: self.item)
//                self.recipesDefaultFromFirebase.append(singleRecipe)
//                if self.recipesDefaultFromFirebase.count == 10 {
//                    self.tableView.reloadData()
//                    //  return
//                }
//            })
//        }
//    }
    
    
    //MARK: Save data to Firebase
    func saveDataToFirebase(text: [String]) {
        
        ref?.child("gifList").setValue(text)
        
        //ref?.child(citiesStr).childByAutoId().setValue(text)
        
    }
    
    // RETRIEVE DATA
    
    func retrieveDataFromFirebase() { //-> [String] {
        
        //var result = [String]()
        //if isSearching {
            ref?.queryOrdered(byChild: "gifList").observe(.childAdded, with: { (snapshot) in
           // ref?.child("gifList").observe(.childAdded, with: { (snapshot) in
                
                
                
                let item = snapshot.value! as! [String]
                //print(item)
                var index = 0
                for _ in 0...24 {
                    let url = item[index]
                    self.gifStrings.append(url)
                    //print(url)
                    index += 1
                    //print(result.count)
                    
                    
//                    result.append(item[String(index)] as! String)
//                    index += 1
                }
 //               print(self.gifStrings.count)
//                if result.count == 25 {
//                    self.myCollectionView.reloadData()
//                    //  return
//                }
//                //self.gifStrings = item
//                //let singleRecipe = Recipe(dictionary: self.item)
//                //self.recipesSearchFromFirebase.append(singleRecipe)
//                
                
                
            })
//        print(result.count)
//        return result
//        } else {
//            
//            ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
//                
//                self.item = snapshot.value! as! [String : AnyObject]
//                let singleRecipe = Recipe(dictionary: self.item)
//                self.recipesDefaultFromFirebase.append(singleRecipe)
//                if self.recipesDefaultFromFirebase.count == 10 {
//                    self.tableView.reloadData()
//                    //  return
//                }
//            })
//        }
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

    //SEARCH BAR TEXT DID CHANGED
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if  searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            gifStrings = getData()
            myCollectionView.reloadData()
            
        }
        
    }
    
    // SEARCH BUTTON CLICKED
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            gifStrings = getData()
            myCollectionView.reloadData()
            print(gifsArray)
            print("COUNT: \(gifsArray.count)")

            //retrieveDataFromFirebase(isSearching: isSearching)
        }
    }


}

