import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let skipButton = UIButton(type: .system)
    private let continueButton = UIButton(type: .system)

    private let pages: [(image: String, text: String)] = [
        ("geofence_image", "Set up secure geofences to manage event access effortlessly."),
        ("faceid", "Activate your digital pass securely using Face ID."),
        ("tracking_image", "Monitor attendee movement in real-time within the geofence.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupButtons()
        setupPageControl()
        setupPages()
    }

    private func setupScrollView() {
        scrollView.isPagingEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
    }

    private func setupPages() {
        let screenWidth = view.frame.width
        let screenHeight = view.frame.height

        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(pages.count), height: screenHeight)

        for (index, page) in pages.enumerated() {
            let pageView = UIView(frame: CGRect(x: CGFloat(index) * screenWidth, y: 0, width: screenWidth, height: screenHeight))

            let imageView = UIImageView(image: UIImage(named: page.image))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            let descriptionLabel = UILabel()
            descriptionLabel.text = page.text
            descriptionLabel.textAlignment = .center
            descriptionLabel.textColor = .darkGray
            descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            descriptionLabel.numberOfLines = 2
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

            pageView.addSubview(imageView)
            pageView.addSubview(descriptionLabel)
            scrollView.addSubview(pageView)

            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: pageView.topAnchor, constant: 150),
                imageView.widthAnchor.constraint(equalTo: pageView.widthAnchor, multiplier: 0.8),
                imageView.heightAnchor.constraint(equalTo: pageView.heightAnchor, multiplier: 0.5),

                descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                descriptionLabel.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
                descriptionLabel.widthAnchor.constraint(equalTo: pageView.widthAnchor, multiplier: 0.8)
            ])
        }
    }

    private func setupButtons() {
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.darkGray, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        view.addSubview(skipButton)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = .systemBlue
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        continueButton.layer.cornerRadius = 8
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Button Actions

    @objc private func skipTapped() {
        navigateToRoleViewController()
    }

    @objc private func continueTapped() {
        let nextPage = pageControl.currentPage + 1
        if nextPage < pages.count {
            let offsetX = CGFloat(nextPage) * scrollView.frame.width
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            pageControl.currentPage = nextPage
        } else {
            navigateToRoleViewController()
        }
    }

    private func navigateToRoleViewController() {
        performSegue(withIdentifier: "role", sender: self)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
