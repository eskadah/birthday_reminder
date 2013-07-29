class BRNotesEditViewController < BRCoreViewController
  def viewWillAppear(animated)
    super
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

  end

    def textViewDidChange(textView)
     puts "User changed the notes Text #{@text_view.text}"
    end

end