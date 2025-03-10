//
//  secondView Controller.swift
//  DigiFence
//
//  Created by admin85 on 15/11/24.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }


    
    var guestList = [
        "Aarav Sharma",
        "Priya Mehta",
        "Rohan Kapoor",
        "Ananya Singh",
        "Ishaan Verma",
        "Dr. Neha Joshi",
        "Prof. Arvind Nair",
        "Sheeba Ma’am",
        "Shashidhara Sir",
        "Utkarsh Mittal",
        "Shashwat Jain",
        "Murugan Sir",
        "Kritika Aggarwal",
        "Rahul Chauhan",
        "Sneha Deshmukh",
        "Aniket Kulkarni",
        "Deepika Sharma",
        "Harsh Vardhan",
        "Nikita Rao",
        "Yash Tiwari",
        "Aditya Raj",
        "Divya Narayan",
        "Tanvi Bhatt",
        "Vivek Tripathi",
        "Meera Sinha",
        "Gaurav Dubey",
        "Dr. Alok Pandey",
        "Ritika Malhotra",
        "Amitabh Saxena",
        "Sonal Kapoor",
        "Vikram Menon",
        "Namrata Das",
        "Rishabh Bansal",
        "Swati Choudhary",
        "Karan Thakur",
        "Pooja Iyer",
        "Avinash Pillai",
        "Manisha Reddy",
        "Mohit Ghosh",
        "Tanya Kaul",
        "Nikhil Srivastava",
        "Rhea Fernandes",
        "Devansh Rawat",
        "Siddhi Joshi",
        "Saurabh Kohli",
        "Jaya Mishra",
        "Anshika Kapoor",
        "Dhruv Patel",
        "Simran Sood",
        "Sudeep Bhattacharya"
    ]

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete
     {
                guestList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension SecondViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = guestList[indexPath.row]
        return cell
    }
    
    
}

