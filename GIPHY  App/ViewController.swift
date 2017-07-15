

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    var gifStrings = [String]()
    var gifsArray = [UIImageView]()
    
    //var gifImage = UIImage()
    var gifView = UIImageView()
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let topConstraint = NSLayoutConstraint(item: myCollectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 100)
//        view.addConstraints([topConstraint])
        
        
        
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(20, 0, 10, 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        
        myCollectionView.collectionViewLayout = layout
        
        gifsArray = getData()
        
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifsArray.count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        
        
        let gifView = gifsArray[indexPath.row]
        cell.addSubview(gifView)
        //cell.gifImage.center.x = cell.frame.size.width/(CGFloat(2.0))
        cell.gifImage = gifView
        
        return cell
    }
    
    // PARSE DATA
    
    func parseData(url: URL) -> [UIImageView] {
        
        var gifsArray = [UIImageView]()
        
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
                let formattedGif = gifStringUrl.replacingOccurrences(of: "\\", with: "")
                
                let gifImage = UIImage.gif(url: formattedGif)
                gifView = UIImageView(image: gifImage)
                //view.addSubview(gifView)
                print(gifImage)
                
                gifsArray.append(gifView)

                

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
    
    func getData() -> [UIImageView] {
        
        var result = [UIImageView]()
        
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
            let gifImage = UIImage.gif(url: gifStringURL)!
            gifView = UIImageView(image: gifImage)
            //myCollectionView.addSubview(gifView)
            print(gifImage)
            result.append(gifView)
            
            
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
            gifsArray = getData()
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
            gifsArray = getData()
            myCollectionView.reloadData()
            print(gifsArray)
            print("COUNT: \(gifsArray.count)")

            //retrieveDataFromFirebase(isSearching: isSearching)
        }
    }


}

