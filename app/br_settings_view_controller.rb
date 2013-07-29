class BRSettingsViewController < BRCoreViewController
  def viewDidLoad
    super

    right =  self.navigationItem.rightBarButtonItem
    right.target = self
    right.action = :saveAndDismiss

  end
end