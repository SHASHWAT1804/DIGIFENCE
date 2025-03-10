import UIKit

protocol EventDetailPopupDelegate: AnyObject {
    func didUpdateEvent(at index: Int, with updatedEvent: ViewController.Event)
    func didDeleteEvent(at index: Int)
}

class EventDetailPopupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: EventDetailPopupDelegate?
    var eventIndex: Int?

    var eventImage: UIImage?
    var eventName: String?
    var venue: String?
    var date: Date?
    var time: Date?
    var adhereName: String?
    var adhereEmail: String?
    var adherePhone: String?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let changeImageButton = UIButton()
    private let nameTextField = UITextField()
    private let venueTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let timePicker = UIDatePicker()
    private let adhereNameTextField = UITextField()
    private let adhereEmailTextField = UITextField()
    private let adherePhoneTextField = UITextField()
    private let deleteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupScrollView()
        setupUI()
        loadEventData()
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterFromKeyboardNotifications()
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        title = "Edit Event"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelChanges))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveChanges))
    }

    // MARK: - ScrollView Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - UI Setup
    private func setupUI() {
           imageView.image = eventImage
           imageView.contentMode = .scaleAspectFill
           imageView.layer.cornerRadius = 12
           imageView.clipsToBounds = true
           imageView.layer.borderWidth = 1
           imageView.layer.borderColor = UIColor.lightGray.cgColor
           imageView.translatesAutoresizingMaskIntoConstraints = false

           changeImageButton.setTitle("Change Image", for: .normal)
           changeImageButton.setTitleColor(.systemBlue, for: .normal)
           changeImageButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
           changeImageButton.translatesAutoresizingMaskIntoConstraints = false

           setupTextField(nameTextField, placeholder: "Event Name", text: eventName)
           setupTextField(venueTextField, placeholder: "Venue", text: venue)
           setupTextField(adhereNameTextField, placeholder: "Coordinator Name", text: adhereName)
           setupTextField(adhereEmailTextField, placeholder: "Coordinator Email", text: adhereEmail)
           setupTextField(adherePhoneTextField, placeholder: "Coordinator Phone", text: adherePhone)
           adherePhoneTextField.keyboardType = .numberPad
           adhereEmailTextField.keyboardType = .emailAddress

           // Create date label
           let dateLabel = UILabel()
           dateLabel.text = "Date:"
           dateLabel.font = UIFont.systemFont(ofSize: 17)
           dateLabel.translatesAutoresizingMaskIntoConstraints = false
           
           // Create time label
           let timeLabel = UILabel()
           timeLabel.text = "Time:"
           timeLabel.font = UIFont.systemFont(ofSize: 17)
           timeLabel.translatesAutoresizingMaskIntoConstraints = false

           datePicker.datePickerMode = .date
           datePicker.preferredDatePickerStyle = .compact
           datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

           timePicker.datePickerMode = .time
           timePicker.preferredDatePickerStyle = .compact
           timePicker.addTarget(self, action: #selector(timeChanged(_:)), for: .valueChanged)

           // Create horizontal stacks for date and time with labels
           let dateStackView = UIStackView(arrangedSubviews: [dateLabel, datePicker])
           dateStackView.axis = .horizontal
           dateStackView.spacing = 8
           dateStackView.alignment = .center
           dateStackView.distribution = .fill
           dateStackView.translatesAutoresizingMaskIntoConstraints = false

           let timeStackView = UIStackView(arrangedSubviews: [timeLabel, timePicker])
           timeStackView.axis = .horizontal
           timeStackView.spacing = 8
           timeStackView.alignment = .center
           timeStackView.distribution = .fill
           timeStackView.translatesAutoresizingMaskIntoConstraints = false

           deleteButton.setTitle("Delete Event", for: .normal)
           deleteButton.setTitleColor(.white, for: .normal)
           deleteButton.backgroundColor = .systemRed
           deleteButton.layer.cornerRadius = 10
           deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
           deleteButton.addTarget(self, action: #selector(confirmDeleteEvent), for: .touchUpInside)

           let stackView = UIStackView(arrangedSubviews: [
               imageView,
               changeImageButton,
               nameTextField,
               venueTextField,
               dateStackView,
               timeStackView,
               adhereNameTextField,
               adhereEmailTextField,
               adherePhoneTextField,
               deleteButton
           ])
           stackView.axis = .vertical
           stackView.spacing = 16
           stackView.alignment = .fill
           stackView.translatesAutoresizingMaskIntoConstraints = false
           contentView.addSubview(stackView)

           NSLayoutConstraint.activate([
               stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
               stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
               stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
               stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

               imageView.heightAnchor.constraint(equalToConstant: 200),
               deleteButton.heightAnchor.constraint(equalToConstant: 50),

               // Add constraints for labels
               dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
               timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
           ])
       }

       @objc private func openGallery() {
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary
           present(imagePicker, animated: true)
       }

       // Implement UIImagePickerControllerDelegate methods
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           guard let selectedImage = info[.originalImage] as? UIImage else { return }
           
           eventImage = selectedImage
           imageView.image = selectedImage
           
           dismiss(animated: true)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           dismiss(animated: true)
       }

    private func setupTextField(_ textField: UITextField, placeholder: String, text: String?) {
        textField.placeholder = placeholder
        textField.text = text
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
    }

    private func loadEventData() {
        datePicker.date = date ?? Date()
        timePicker.date = time ?? Date()
    }
    private func registerForKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        private func unregisterFromKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self)
        }

        @objc private func keyboardWillShow(_ notification: Notification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                scrollView.contentInset.bottom = keyboardFrame.height + 20
            }
        }

        @objc private func keyboardWillHide(_ notification: Notification) {
            scrollView.contentInset.bottom = 0
        }


    // MARK: - Date Picker Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        date = sender.date
    }

    @objc private func timeChanged(_ sender: UIDatePicker) {
        time = sender.date
    }

 
    @objc private func saveChanges() {
        guard let index = eventIndex else { return }

        let updatedEvent = ViewController.Event(
            image: imageView.image,
            name: nameTextField.text ?? "",
            date: formatDate(date ?? Date()),
            time: formatTime(time ?? Date()),
            venue: venueTextField.text ?? "",
            adhereName: adhereNameTextField.text ?? "",
            adhereEmail: adhereEmailTextField.text ?? "",
            adherePhone: adherePhoneTextField.text ?? ""
        )

        delegate?.didUpdateEvent(at: index, with: updatedEvent)
        dismiss(animated: true)
    }

    @objc private func confirmDeleteEvent() {
        delegate?.didDeleteEvent(at: eventIndex!)
        dismiss(animated: true)
    }

    @objc private func cancelChanges() {
        dismiss(animated: true)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
