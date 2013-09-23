class BirthdayTableViewCell   < UITableViewCell
  attr_reader :birthday

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
  end



end

