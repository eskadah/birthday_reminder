class BRNotesEditViewController < BRCoreViewController
  attr_accessor :birthday
  def viewWillAppear(animated)
    super
    @text_view.text = birthday.notes
    @text_view.becomeFirstResponder
  end


  def viewDidLoad
    super

    left = self.navigationItem.leftBarButtonItem
    left.target = self
    left.action = :cancelAndDismiss

    @save_button =  self.navigationItem.rightBarButtonItem
    @save_button.target = self
    @save_button.action = :saveAndDismiss

    @text_view = view.viewWithTag 1
    @text_view.delegate = self

    BRStyleSheet.styleTextView @text_view

  end

    def textViewDidChange(textView)
     #puts "User changed the notes Text #{@text_view.text}"
      birthday.notes = @text_view.text

    end

  def cancelAndDismiss
    BRDModel.sharedInstance.cancelChanges
    super
  end

  def saveAndDismiss
    BRDModel.sharedInstance.saveChanges
    super
  end



end