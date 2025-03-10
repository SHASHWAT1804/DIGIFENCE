import UIKit

class TrackViewController: UIViewController {
    
// Connect the tableView in Storyboard
    
    @IBOutlet weak var tableView: UITableView!
    var List = ["View Guests List", "Track Your Guests", "Add a Guest", "Edit Fence"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = List[indexPath.row]
        
        switch selectedOption {
        case "View Guests List":
            performSegue(withIdentifier: "showGuestList", sender: self)
        case "Track Your Guests":
            performSegue(withIdentifier: "showTrackGuests", sender: self)
        case "Add a Guest":
            performSegue(withIdentifier: "showAddGuest", sender: self)
        case "Edit Fence":
            performSegue(withIdentifier: "showEditFence", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGuestList" {
            if segue.destination is SecondViewController {
                // Pass any data if necessary
                print("Navigating to SecondViewController")
            }
        } else if segue.identifier == "showEditFence" {
            if segue.destination is GeofenceViewController {
                // Pass any data if necessary
                print("Navigating to EditFenceViewController")
            }
        }
    }
}

extension TrackViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return List.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell.textLabel?.text = List[indexPath.row]
        return cell
    }
}
