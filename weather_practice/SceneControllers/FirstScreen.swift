import UIKit
import CoreLocation

class FirstScreenViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()
    lazy var locationTextfield = UITextField.createTextField(placeholder: "Enter Location")
    lazy var ORtext = UILabel.createLabel(font: UIFont.Black(size: 20), textAlingment: .center, text: "OR")
    
    lazy var findLocationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(
            "Use current location",
            attributes: .init([.font: UIFont.regular(size: 15)])
        )
        var backgroundConfig = UIBackgroundConfiguration.clear()
        backgroundConfig.cornerRadius = 10.0
        backgroundConfig.strokeWidth = 1.5
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        if (6..<19).contains(currentHour) {
            config.baseForegroundColor = .darkGray
            backgroundConfig.strokeColor = .darkGray
        } else {
            config.baseForegroundColor = .systemYellow
            backgroundConfig.strokeColor = .systemYellow
        }
        
        config.background = backgroundConfig
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14)
        let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.locationButtonTapped()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        updateBackground()
        setupUIAndConstraints()
    }
    
    @objc private func locationButtonTapped() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        case .denied, .restricted:
            showLocationDeniedAlert()
        @unknown default:
            
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        UserDefaults.standard.set(latitude, forKey: "lastLatitude")
        UserDefaults.standard.set(longitude, forKey: "lastLongitude")
        
        weatherService.fetchCurrentWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weatherData):
                self.getDisplayName(from: location) { displayName in
                    self.goToSecondScreen(locationName: displayName, weatherData: weatherData)
                }
            case .failure(let error):
                print("Error loading weather by coordinates: \(error)")
                self.showErrorAlert(message: "Failed to load weather for the current location.")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Geolocation error \(error.localizedDescription)")
        showErrorAlert(message: "Could not determine your location. Please check your settings and try again later.")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let locationText = textField.text, !locationText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Empty input")
            return false
        }
        
        
        
        weatherService.fetchCurrentWeather(cityName: locationText) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weatherData):
                self.goToSecondScreen(locationName: locationText, weatherData: weatherData)
            case .failure:
                self.showErrorAlert(message: "Could not find weather for the city'\(locationText)'.")
            }
        }
        return true
    }
    
    func goToSecondScreen(locationName: String, weatherData: WeatherModel) {
        let mainScreen = MainScreenViewController()
        
        mainScreen.cityName = locationName
        mainScreen.weatherData = weatherData
        navigationController?.pushViewController(mainScreen, animated: true)
    }
    
    private func getDisplayName(from location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "en_US")
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { (placemarks, error) in
            if let placemark = placemarks?.first {
                let name = placemark.locality ?? placemark.administrativeArea ?? "Current Location"
                completion(name)
            } else {
                completion("Current Location")
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if self.presentedViewController == nil {
            present(alert, animated: true)
        }
    }
    
    private func showLocationDeniedAlert() {
        let message = "To detect the city automatically, please allow access to your location in the device settings."
        let alert = UIAlertController(title: "Access denied", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupDelegates() {
        locationManager.delegate = self
        locationTextfield.delegate = self
    }
    
    @objc private func updateBackground() {
        let hour = Calendar.current.component(.hour, from: Date())
        if (6..<19).contains(hour) {
            setupDayBackground()
        } else {
            setupNightBackground()
        }
    }
    
    private func setupDayBackground() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 102/255.0, green: 178/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 178/255.0, green: 216/255.0, blue: 255/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupNightBackground() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUIAndConstraints() {
        view.addSubview(locationTextfield)
        view.addSubview(ORtext)
        view.addSubview(findLocationButton)
        
        NSLayoutConstraint.activate([
            locationTextfield.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            locationTextfield.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            locationTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            locationTextfield.heightAnchor.constraint(equalToConstant: 50),
            
            ORtext.topAnchor.constraint(equalTo: locationTextfield.bottomAnchor, constant: 20),
            ORtext.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            findLocationButton.topAnchor.constraint(equalTo: ORtext.bottomAnchor, constant: 20),
            findLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
