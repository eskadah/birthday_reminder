class BRCoreViewController  < UIViewController

def viewDidLoad
  super
  view.backgroundColor = UIColor.grayColor
end

def cancelAndDismiss
  puts 'cancel'
  self.dismissModalViewControllerAnimated(true,completion:lambda {puts 'dismissed'}[])
end

def saveAndDismiss
  puts 'saved'
  self.dismissModalViewControllerAnimated(true,completion:lambda {puts 'dismissed'}[])
end


end