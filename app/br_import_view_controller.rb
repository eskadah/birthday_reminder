class BRImportViewController  < BRCoreViewController
  attr_accessor :birthdays
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
    puts @table_view
  end

  def didTapButton(sender)

  end

  def didTapSelectButton(sender)

  end

  def didTapSelectNoneButton(sender)

  end

  def tableView(tableView, numberOfRowsInSection:number)
    puts 'number of rows called'
    puts birthdays.size
      birthdays.size

  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cell = @table_view.dequeueReusableCellWithIdentifier('Cell')
  end
end