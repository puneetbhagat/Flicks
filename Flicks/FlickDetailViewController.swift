//
//  FlickDetailViewController.swift
//  Flicks
//
//  Created by Bhagat, Puneet on 4/2/17.
//  Copyright © 2017 Puneet Bhagat. All rights reserved.
//

import UIKit

class FlickDetailViewController: UIViewController {

    var imageUrlString: String = ""
    var flickTitleString: String = ""
    var flickOverviewString: String = ""
    var flickReleaseDateString: String = ""
    @IBOutlet weak var flickImageView: UIImageView!
    @IBOutlet weak var flickTitleLabel: UILabel!
    @IBOutlet weak var flickOverviewLabel: UILabel!
    @IBOutlet weak var flickReleaseDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let imageUrl = URL(string: self.imageUrlString) {
            flickImageView.setImageWith(imageUrl)
            flickTitleLabel.text = flickTitleString
            flickOverviewLabel.text = flickOverviewString
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
//            print("dateformat")
//            print(flickReleaseDateString)
//            print(dateFormatter.date(from: flickReleaseDateString))
//            dateFormatter.dateStyle = .long
//            print(dateFormatter.string(for: flickReleaseDateString))
//            flickReleaseDateLabel.text = dateFormatter.string(for: flickReleaseDateString)
            
            flickReleaseDateLabel.text = flickReleaseDateString
        }
        else
        {
            //do nothing
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
