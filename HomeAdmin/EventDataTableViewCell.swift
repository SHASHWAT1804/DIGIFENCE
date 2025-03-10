import UIKit

class EventDataTableViewCell: UITableViewCell {
    
    var eventOImage: UIImageView!
    var eventOName: UILabel!
    var eventODate: UILabel!
    var eventOTime: UILabel!
    var eventOVenue: UILabel!
    var eventOCard: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        eventOImage = UIImageView()
        eventOName = UILabel()
        eventODate = UILabel()
        eventOTime = UILabel()
        eventOVenue = UILabel()
        eventOCard = UIView()
        
        contentView.addSubview(eventOImage)
        contentView.addSubview(eventOName)
        contentView.addSubview(eventODate)
        contentView.addSubview(eventOTime)
        contentView.addSubview(eventOVenue)
        contentView.addSubview(eventOCard)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // Disable Autoresizing Mask Translation
        eventOImage.translatesAutoresizingMaskIntoConstraints = false
        eventOName.translatesAutoresizingMaskIntoConstraints = false
        eventODate.translatesAutoresizingMaskIntoConstraints = false
        eventOTime.translatesAutoresizingMaskIntoConstraints = false
        eventOVenue.translatesAutoresizingMaskIntoConstraints = false
        eventOCard.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup Constraints
        NSLayoutConstraint.activate([
            // Image View Constraints
            eventOImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            eventOImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            eventOImage.widthAnchor.constraint(equalToConstant: 112), // Image Size
            eventOImage.heightAnchor.constraint(equalToConstant: 112),
            
            // Event Name Constraints
            eventOName.leadingAnchor.constraint(equalTo: eventOImage.trailingAnchor, constant: 20),
            eventOName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            
            // Event Date Constraints
            eventODate.leadingAnchor.constraint(equalTo: eventOImage.trailingAnchor, constant: 20),
            eventODate.topAnchor.constraint(equalTo: eventOName.bottomAnchor, constant: 8),
            
            // Event Time Constraints
            eventOTime.leadingAnchor.constraint(equalTo: eventOImage.trailingAnchor, constant: 20),
            eventOTime.topAnchor.constraint(equalTo: eventODate.bottomAnchor, constant: 5),
            
            // Event Venue Constraints
            eventOVenue.leadingAnchor.constraint(equalTo: eventOImage.trailingAnchor, constant: 20),
            eventOVenue.topAnchor.constraint(equalTo: eventOTime.bottomAnchor, constant: 5),
            
            // Event Card Constraints
            eventOCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30), // Reduced card width
            eventOCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30), // Reduced card width
            eventOCard.topAnchor.constraint(equalTo: eventOImage.bottomAnchor, constant: 10), // Adjusted card spacing
            eventOCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
        
        // Styling for Image View
        eventOImage.layer.cornerRadius = 10
        eventOImage.clipsToBounds = true
        
        // Styling for Labels
        eventOName.font = UIFont.systemFont(ofSize: 22, weight:.bold)
        eventODate.font = UIFont.systemFont(ofSize: 18)
        eventODate.textColor = .gray
        eventOTime.font = UIFont.systemFont(ofSize: 18)
        eventOTime.textColor = .gray
        eventOVenue.font = UIFont.systemFont(ofSize: 18)
        eventOVenue.textColor = .gray
        
        // Styling for the Card View
        eventOCard.layer.cornerRadius = 12
        eventOCard.layer.shadowColor = UIColor.black.cgColor
        eventOCard.layer.shadowOpacity = 0.1
        eventOCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        eventOCard.layer.shadowRadius = 5
    }
}
