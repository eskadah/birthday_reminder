class BRCoreViewController  < UIViewController

def viewDidLoad
  super
  view.backgroundColor = UIColor.grayColor
  backgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed 'app-background.png')
  view.insertSubview(backgroundView, atIndex:0)
end

def cancelAndDismiss
  puts 'cancel'
  self.dismissModalViewControllerAnimated(true,completion:lambda {puts 'dismissed'}[])
end

def saveAndDismiss
  puts 'saved'

  self.dismissViewControllerAnimated(true,completion:lambda {puts 'dismissed'}[])
end


end