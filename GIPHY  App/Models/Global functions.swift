
import Foundation
import UIKit
import SystemConfiguration
import CoreData

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
    
    let gifImage = UIImage.gif(url: string)
    let gifView = UIImageView(image: gifImage)
    
    return gifView
}


// MARK: CORE DATA

// save data to Core Data
func saveToCoreData(array: [String], context: NSManagedObjectContext) {
    
    var imageViewArray = [UIImageView]()
    
    
    let entity = NSEntityDescription.insertNewObject(forEntityName: "Gif", into: context)
    
    for i in array {
        DispatchQueue.global().async {
            let imageView = stringToView(string: i)
            DispatchQueue.main.async {
                imageViewArray.append(imageView)
            }
        }
        
        
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


func fetchFromCoreData(context: NSManagedObjectContext) -> [UIImageView] {
    
    var imageViewArray = [UIImageView]()
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Gif")
    request.returnsObjectsAsFaults = false
    
    do {
        let results = try context.fetch(request)
        
        if results.count > 0 {
            for result in results {
                
                
                // fetch data
                if let gifImageViewArray = (result as AnyObject).value(forKey: "arrayOfStringUrls") as? [UIImageView] {
                    
                    imageViewArray = gifImageViewArray
                    break
                }
                
            }
            
        }
    } catch {
        print("Error: \(error)")
    }
    return imageViewArray
}

func deleteDataInCoreData(context: NSManagedObjectContext) {
    
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

// PARSE DATA

func parseData(url: URL) -> [String] {
    
    var gifsArray = [String]()
    
    do {
        
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
        let mainDictionary = json["data"] as! [[String : Any]]
        
        for i in mainDictionary {
            
            
            let images = i["images"] as! [String : Any]
            let appropriateSize = images["fixed_height_small"] as! [String : Any]
            let gifStringUrl = appropriateSize["url"] as! String
            gifsArray.append(gifStringUrl)
            
        }
    }
    catch {
        print(error)
    }
    return gifsArray
}

// GET DATA

func getData(input: String) -> [String] {
    
    var result = [String]()
    
    let inputAddingPercentEncoding = input.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
    
    let searchUrl = URL(string: "http://api.giphy.com/v1/gifs/search?q=\(inputAddingPercentEncoding!)&api_key=c61e8bb1a9c14a6e8dc6fb15d211b4b5")
    result = parseData(url: searchUrl!)
    
    return result
}




