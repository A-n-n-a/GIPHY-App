

import UIKit
import Firebase
import FirebaseDatabase
import CoreData
import SystemConfiguration


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        
      
        if isConnectedToNetwork() == false {
            gifsViewsFromCoreData = fetchFromCoreData(context: context)
            myCollectionView.reloadData()

            
        } else {
            retrieveDataFromFirebase()
        }
        
        //deleteDataInCoreData(context: context)


        
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if gifStrings.count == 0 {
            self.myCollectionView.reloadData()
        }
        
        var count = Int()
        
        if isConnectedToNetwork() == false {
            if gifsViewsFromCoreData.count == 0 {
                myCollectionView.reloadData()
            }
            count = gifsViewsFromCoreData.count

        } else {
            count = gifStrings.count
        }
        
        
        return count
    }
    
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        if isConnectedToNetwork() == false {
            
            DispatchQueue.global().async {
                let gifView = self.gifsViewsFromCoreData[indexPath.row]
                
                DispatchQueue.main.async {
                    cell.gifImage = gifView
                    cell.addSubview(gifView)
                }
            }
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
    
    
    
    
    //MARK: FIREBASE
    
    func saveDataToFirebase(text: [String]) {
        
        ref?.child("gifList").setValue(text)
        
    }
    
    func retrieveDataFromFirebase() {
        
        ref?.queryOrdered(byChild: "gifList").observe(.childAdded, with: { (snapshot) in
           
            let item = snapshot.value! as! [String]
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
    
    



    //MARK: SEARCH BAR
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if  searchBar.text == "" {
            
            view.endEditing(true)
            retrieveDataFromFirebase()
            self.myCollectionView.reloadData()
            
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text == nil || searchBar.text == "" {

            view.endEditing(true)
        } else {

            gifStrings = getData(input: searchBar.text!)
            myCollectionView.reloadData()
            saveToCoreData(array: gifStrings, context: context)

        }
    }
    
    //MARK: PREPARE FOR GEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let destViewController = segue.destination as! LargeGifViewController
        
        let selectedRowIndex = self.myCollectionView.indexPath(for: sender as! CollectionViewCell)
        selectedRow = self.myCollectionView.cellForItem(at: selectedRowIndex!) as! CollectionViewCell
        if isConnectedToNetwork() == true {
            destViewController.stringGif = gifStrings[(selectedRowIndex?.row)!]
        } else {
            destViewController.recievedGif = gifsViewsFromCoreData[(selectedRowIndex?.row)!]
        }
    }
    
    
    


}

