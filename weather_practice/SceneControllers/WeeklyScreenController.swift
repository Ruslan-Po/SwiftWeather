import UIKit

class WeeklyScreenController: UIViewController {
    


    private func setupNightBackground() {
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
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
    
    
    @objc private func UPDbgImage(){
        let hour = Calendar.current.component(.hour, from: Date())
        if hour>=6 && hour<19{
            setupDayBackground()
            return
        }else{
            setupNightBackground()}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UPDbgImage()
      
        
        NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(UPDbgImage),
                  name: UIApplication.didBecomeActiveNotification,
                  object: nil
              )
  
    }
    deinit {
         NotificationCenter.default.removeObserver(self)
     }
}

