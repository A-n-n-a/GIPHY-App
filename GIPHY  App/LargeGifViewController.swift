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
        
        print(recievedGif)
        print(stringGif)
        
        let largeGifImage = UIImage.gif(url: stringGif)
        let largeGifImageView = UIImageView(image: largeGifImage)
        
        //largeGifView.frame = recievedGif.frame
        largeGifView.image = largeGifImage
        //largeGifView.image = #imageLiteral(resourceName: "images (1).jpeg")

        // Do any additional setup after loading the view.
    }

   }
