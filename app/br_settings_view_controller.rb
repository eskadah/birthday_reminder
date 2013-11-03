class BRSettingsViewController  < UITableViewController

  def viewDidLoad
    super

    p @tableCellDaysBefore
    p @tableCellNotificationTime
    @doneButton = self.navigationItem.rightBarButtonItem
    @doneButton.target = self
    @doneButton.action = 'didClickDoneButton:'

    backgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed('app-background.png'))
    tableView.backgroundView = backgroundView

  end

  def viewWillAppear(animated)
    super
    cellArray = tableView.visibleCells
    @tableCellDaysBefore = cellArray.first
    @tableCellNotificationTime = cellArray.last
    @tableCellNotificationTime.detailTextLabel.text = BRDSettings.sharedInstance.titleForNotificationTime
    @tableCellDaysBefore.detailTextLabel.text = BRDSettings.sharedInstance.titleForDaysBefore(BRDSettings.sharedInstance.daysBefore)


  end

  def didClickDoneButton(sender)
    self.dismissViewControllerAnimated(true, completion: nil)
  end

  def createSectionHeaderWithLabel(text)
    view = UIView.alloc.initWithFrame [[0,0],[320,40.0]]
    label = UILabel.alloc.initWithFrame [[10.0,15.0],[300.0,20.0]]
    label.backgroundColor = UIColor.clearColor
    BRStyleSheet.styleLabel(label,withType:'BRLabelTypeLarge')
    label.text = text
    view.addSubview label
    view
  end

  def tableView(tableView,heightForHeaderInSection:section )
    40.0
  end

  def tableView(tableView,viewForHeaderInSection:section)
    createSectionHeaderWithLabel 'Reminders'
  end

end