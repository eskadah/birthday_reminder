class BirthdayTableViewCell   < UITableViewCell
  attr_reader :birthday
  attr_accessor :birthdayImport

  def iconView
    @icon_view = contentView.viewWithTag 1
    BRStyleSheet.styleRoundCorneredView(@icon_view)
    @icon_view
  end

  def iconView=(x)
    @icon_view = x
  end

  def remainingDaysImageView
    @remaining_days_image_view = contentView.viewWithTag 2
  end

  def remainingDaysImageView=(x)
    @remaining_days_image_view = x
  end

  def nameLabel

    @name_label = contentView.viewWithTag 3
    BRStyleSheet.styleLabel(@name_label,withType:'BRLabelTypeName') if @name_label
    @name_label
  end

  def nameLabel=(x)
    @name_label = x
  end

  def birthdayLabel
    @birthday_label = contentView.viewWithTag 4
    BRStyleSheet.styleLabel(@birthday_label,withType:'BRLabelTypeBirthdayDate') if @birthday_label
    @birthday_label
  end

  def birthdayLabel=(x)
    @birthday_label = x
  end

  def remainingDaysLabel
    @remaining_days_label = contentView.viewWithTag 5
  end

  def remainingDaysLabel=(x)
     @remaining_days_label = x
  end


  def remainingDaysSubTextLabel
    @remaining_days_sub_text_label = contentView.viewWithTag 6
    BRStyleSheet.styleLabel(@remaining_days_label,withType:'BRLabelTypeDaysUntilBirthday') if @remaining_days_label
    @remaining_days_sub_text_label
  end

  def remainingDaysSubTextLabel=(x)
    @remaining_days_sub_text_label = x
  end

  def birthday=(birthday)

    @birthday = birthday
    nameLabel.text = @birthday.name
    days = @birthday.remainingDaysUntilNextBirthday

    if days == 0
      remainingDaysLabel.text = remainingDaysSubTextLabel.text = ''
      remainingDaysImageView.image = UIImage.imageNamed 'icon-birthday-cake.png'
    else
      remainingDaysLabel.text = "#{days}"
      remainingDaysSubTextLabel.text = days == 1 ? 'more day' : 'more days'
      remainingDaysImageView.image = UIImage.imageNamed 'icon-days-remaining.png'
    end

    birthdayLabel.text = @birthday.birthdayTextToDisplay

    if @birthday.imageData == nil
      if @birthday.picURL && @birthday.picURL.length > 0
        self.iconView.setImageWithRemoteFileURL(@birthday.picURL,placeHolderImage:(UIImage.imageNamed('icon-birthday-cake.png')))
      else
        self.iconView.image = UIImage.imageNamed('icon-birthday-cake.png')
      end
    else
      self.iconView.image = UIImage.imageWithData(@birthday.imageData)
    end
  end

  def birthdayImport=(birthdayImport)
    @birthdayImport = birthdayImport
    nameLabel.text = @birthdayImport.name
    days = @birthdayImport.remainingDaysUntilNextBirthday

    if days == 0
      remainingDaysLabel.text = remainingDaysSubTextLabel.text = ''
      remainingDaysImageView.image = UIImage.imageNamed 'icon-birthday-cake.png'
    else
      remainingDaysLabel.text = "#{days}"
      remainingDaysSubTextLabel.text = days == 1 ? 'more day' : 'more days'
      remainingDaysImageView.image = UIImage.imageNamed 'icon-days-remaining.png'
    end

    birthdayLabel.text = @birthdayImport.birthdayTextToDisplay
    if @birthdayImport.imageData == nil
      if @birthdayImport.picURL && @birthdayImport.picURL.length > 0
        puts ' birthda import picurl has length'
        puts  @birthdayImport.picURL
        puts  birthdayImport.picURL
        iconView.setImageWithRemoteFileURL(@birthdayImport.picURL,placeHolderImage:UIImage.imageNamed('icon-birthday-cake.png'))
      else
        puts ' birthda import picurl has no length'
        self.iconView.image = UIImage.imageNamed('icon-birthday-cake.png')
      end
    else
      self.iconView.image = UIImage.imageWithData(@birthdayImport.imageData)
    end
  end



end

