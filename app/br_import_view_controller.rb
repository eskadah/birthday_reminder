class BRImportViewController  < BRCoreViewController
  attr_accessor :birthdays,:selectedIndexPathToBirthday
  def birthdays
    @birthdays ||= []
  end

  def viewDidLoad
    super
    @table_view = view.viewWithTag 1
    @table_view.dataSource = self
    @table_view.delegate = self
    leftButton = navigationItem.leftBarButtonItem
    leftButton.target = self
    leftButton.action = :cancelAndDismiss
    @importButton = navigationItem.rightBarButtonItem
    @importButton.target = self
    @importButton.action = 'didTapImportButton:'
    toolbarItems[1].target = self
    toolbarItems[1].action = 'didTapSelectAllButton:'
    toolbarItems[2].target = self
    toolbarItems[2].action = 'didTapSelectNoneButton:'

  end

  def viewWillAppear(animated)
    super
    updateImportButton
  end

  def didTapImportButton(sender)
    birthdaysToImport = selectedIndexPathToBirthday.allValues
    BRDModel.sharedInstance.importBirthdays(birthdaysToImport)
    self.dismissViewControllerAnimated(true, completion: nil)

  end

  def didTapSelectAllButton(sender)

    birthdays.each_with_index do |birthdayImport,i|
      indexPath = NSIndexPath.indexPathForRow(i,inSection:0)
      selectedIndexPathToBirthday[indexPath] = birthdayImport
      @table_view.reloadData
      updateImportButton
    end

  end

  def didTapSelectNoneButton(sender)
     selectedIndexPathToBirthday.clear
     @table_view.reloadData
     updateImportButton
  end

  def tableView(tableView, numberOfRowsInSection:number)
    puts 'number of rows called'
    puts birthdays.size
      birthdays.size

  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = @table_view.dequeueReusableCellWithIdentifier('Cell')
    birthdayImport = birthdays[indexPath.row]
    brTableCell = cell
    brTableCell.birthdayImport = birthdayImport

    #if birthdayImport.imageData == nil
    #  brTableCell.iconView.image = UIImage.imageNamed "icon-birthday-cake.png"
    #else
    #  brTableCell.iconView.image = UIImage.imageWithData birthdayImport.imageData
    #end

    backgroundImage = indexPath.row == 0 ? UIImage.imageNamed("table-row-background.png") : UIImage.imageNamed('table-row-icing-background.png')
    brTableCell.backgroundView = UIImageView.alloc.initWithImage backgroundImage
    updateAccessoryForTableCell(cell,atIndexPath:indexPath)

    cell
  end

  def selectedIndexPathToBirthday
    @selectedIndexPathToBirthday||= {}
  end

  def updateImportButton
     @importButton.enabled = selectedIndexPathToBirthday.size > 0
  end

  def selectedAtIndexPath?(indexPath)
    @selectedIndexPathToBirthday.include?(indexPath)
  end

  def updateAccessoryForTableCell(tableCell,atIndexPath:indexPath)
    if selectedAtIndexPath?(indexPath)
      imageView = UIImageView.alloc.initWithImage(UIImage.imageNamed('icon-import-selected.png'))
    else
      imageView = UIImageView.alloc.initWithImage(UIImage.imageNamed('icon-import-not-selected.png'))
    end
    tableCell.accessoryView = imageView
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)

    isSelected = selectedAtIndexPath?(indexPath)
    birthdayImport = birthdays[indexPath.row]
    if isSelected
       self.selectedIndexPathToBirthday.delete indexPath
    else
      selectedIndexPathToBirthday[indexPath] = birthdayImport
    end
    updateAccessoryForTableCell(tableView.cellForRowAtIndexPath(indexPath),atIndexPath:indexPath)
    updateImportButton
  end


end