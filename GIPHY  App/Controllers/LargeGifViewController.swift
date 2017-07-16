//
//  LargeGifViewController.swift
//  GIPHY  App
//
//  Created by Anna on 15.07.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit

class LargeGifViewController: UIViewController {

    @IBOutlet weak var largeGifView: UIImageView!
    
    var stringGif = String()
    
    var recievedGif = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isConnectedToNetwork() == true {
        
            let largeGifImage = UIImage.gif(url: stringGif)
            largeGifView.image = largeGifImage

        } else {
            
            largeGifView.image = recievedGif.image
        }
    }

}
