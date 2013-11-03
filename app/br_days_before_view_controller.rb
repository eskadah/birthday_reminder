class BRDaysBeforeViewController <UITableViewController

  def viewDidLoad
    super
    backgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed 'app-background.png')
    tableView.backgroundView = backgroundView
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier('Cell')
    cell.textLabel.text = BRDSettings.sharedInstance.titleForDaysBefore(indexPath.row)
    cell.accessoryType = BRDSettings.sharedInstance.daysBefore == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone
    cell
  end

  def tableView(tableView, numberOfRowsInSection: section)
    8
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    if indexPath.row == BRDSettings.sharedInstance.daysBefore
      return #tableView.deselectRowAtIndexPath(indexPath,animated:false)
    end

    oldIndexPath = NSIndexPath.indexPathForRow(BRDSettings.sharedInstance.daysBefore, inSection: 0)
    BRDSettings.sharedInstance.daysBefore = indexPath.row
    tableView.reloadRowsAtIndexPaths([oldIndexPath,indexPath],withRowAnimation:UITableViewRowAnimationNone)

  end

end