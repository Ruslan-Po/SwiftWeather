import UIKit

extension UIStackView{
    static func additionBlock(topTitle: String, bottomAdditionTitle: String)->UIStackView{
        let currentHour = Calendar.current.component(.hour, from: Date())
        let topLabel = UILabel()
        topLabel.text = topTitle
        topLabel.textAlignment = .center
        topLabel.font = .systemFont(ofSize: 16, weight: .bold)
        topLabel.textColor = .white
        
        let bottomLabel = UILabel()
        bottomLabel.shadowColor = UIColor.systemGray2
        bottomLabel.shadowOffset = CGSize(width: 1, height: 2)
        bottomLabel.text = bottomAdditionTitle
        bottomLabel.textAlignment = .center
        bottomLabel.font = UIFont.regular(size: 45)
        
        
        if (6..<19).contains(currentHour) {
            bottomLabel.textColor = .gray
               } else {
            bottomLabel.textColor = .systemYellow
               }
        
        
        
        bottomLabel.tag = 101
        
        let titleStack = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 5
        titleStack.alignment = .center
        
        return titleStack
        
    }
    
    static func createBlock(imageName: String, topTitle:String, bottomTitle: String) -> UIStackView{
        
        let ImageView = UIImageView(image:  UIImage(named: imageName))
        ImageView.contentMode = .scaleAspectFit
        ImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        ImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let topLabel = UILabel()
        topLabel.text = topTitle
        topLabel.font = .systemFont(ofSize: 16, weight: .bold)
        topLabel.textColor = .white
        
        let bottomLabel = UILabel()
        bottomLabel.text = bottomTitle
        bottomLabel.font = .systemFont(ofSize: 14)
        bottomLabel.textColor = .white
        bottomLabel.tag = 101 
            
        let titleStack = UIStackView(arrangedSubviews: [topLabel, bottomLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 2
        titleStack.alignment = .leading
        
        let blockStack = UIStackView(arrangedSubviews: [ImageView, titleStack])
        blockStack.axis = .horizontal
        blockStack.spacing = 8
        blockStack.alignment = .center
        return blockStack
        }
    
    func updateBottomTitle(_ newText: String) {
           if let bottomLabel = self.viewWithTag(101) as? UILabel {
               bottomLabel.text = newText
           }
       }
    
    func updateBottomAdditionTitle(_ newText: String) {
           if let bottomLabel = self.viewWithTag(101) as? UILabel {
               bottomLabel.text = newText
           }
       }
}

extension UILabel{
    static func createLabel(font: UIFont,textAlingment: NSTextAlignment, text: String) -> UILabel {
        
    let currentHour = Calendar.current.component(.hour, from: Date())
      
       let label = UILabel()
       label.textColor = .white
       label.text = text
       label.textAlignment = .left
        if (6..<19).contains(currentHour) {
                   label.textColor = .gray
               } else {
                   label.textColor = .systemYellow
               }
       label.font = font
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }
}

extension UIFont{
    static func Light (size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Lato-Light", size: size) else {
            fatalError("Не удалось загрузить шрифт Lato-Light.")
        }
        return font
    }
    static func regular(size:CGFloat)->UIFont{
        guard let font = UIFont(name: "Lato-Regular",size: size) else{
            fatalError("Не удалось загрузить шрифт Lato-Regular.")
        }
        return font
    }
    static func Black(size:CGFloat)->UIFont{
        guard let font = UIFont(name: "Lato-Black",size: size) else{
            fatalError("Не удалось загрузить шрифт Lato-Black.")
        }
        return font
    }
}


extension UIButton{
    static func createNextButton (selector: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
         config.title = "Next Days"
         config.image = UIImage(systemName: "chevron.right")
         config.imagePlacement = .trailing
         config.imagePadding = 8 
         config.baseForegroundColor = .white
         let button = UIButton(configuration: config, primaryAction: nil)
         button.addTarget(target, action: selector, for: .touchUpInside)
         button.translatesAutoresizingMaskIntoConstraints = false
         return button
    }
}

extension Date{
    static func dateFormatter() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let localDateString = formatter.string(from: currentDateTime)
        return localDateString
    }
    
    static func getGreetingbyTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        case 18..<24:
            return "Good Evening"
        default :
            return "Good Night"
        }
    }
}


