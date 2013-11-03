class BRImportFacebookViewController < BRImportViewController
  def viewDidLoad
    super
  end

  def viewWillAppear(animated)
    super
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'handleFacebookBirthdaysDidUpdate:', name: 'BRNotificationFaceBookBirthdaysDidUpdate', object: BRDModel.sharedInstance)

    BRDModel.sharedInstance.fetchFacebookBirthdays
  end

  def viewWillDisappear(animated)
    super
    NSNotificationCenter.defaultCenter.removeObserver(self, name: 'BRNotificationFaceBookBirthdaysDidUpdate', object: BRDModel.sharedInstance)
  end

  def handleFacebookBirthdaysDidUpdate(notification)
    userInfo = notification.userInfo
    self.birthdays = userInfo['birthdays']
    @table_view.reloadData
  end

end