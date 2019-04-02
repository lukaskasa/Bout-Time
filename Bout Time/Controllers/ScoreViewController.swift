//
//  ScoreViewController.swift
//  Bout Time
//
//  Created by Lukas Kasakaitis on 30.03.19.
//  Copyright © 2019 Lukas Kasakaitis. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    var score: String = ""
    
    @IBOutlet weak var scoreLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel?.text = score
    }

    @IBAction func playAgain(_ sender: Any) {
         performSegue(withIdentifier: "playAgain", sender: nil)
    }
    

}
