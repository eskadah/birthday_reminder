class BRImportAddressBookViewController < BRImportViewController
  def viewWillAppear(animated)
    super
    BRDModel.sharedInstance.fetchAddressBookBirthdays
    NSNotificationCenter.defaultCenter.addObserver(self, selector:'handleAddressBookBirthdaysDidUpdate:', name:'BRNotificationAddressBookBirthdaysDidUpdate', object: BRDModel.sharedInstance)
    puts NSNotificationCenter.defaultCenter
    true
  end

  def viewWillDisappear(animated)
    puts 'dissappear called'
    super
    NSNotificationCenter.defaultCenter.removeObserver(self,name:'BRNotificationAddressBookBirthdaysDidUpdate', object: BRDModel.sharedInstance)
  end

  def handleAddressBookBirthdaysDidUpdate(notification)
    puts 'handleAddressBookBirthdaysDidUpdate'
    userInfo = notification.userInfo
    self.birthdays = userInfo['birthdays']
    @table_view.reloadData

    if birthdays.size == 0
      alert = UIAlertView.alloc.initWithTitle(nil, message: 'Sorry No Birthdays Found in your addressbook', delegate: nil, cancelButtonTitle: nil, otherButtonTitles:'OK',nil)
      alert.show
    end
  end
end