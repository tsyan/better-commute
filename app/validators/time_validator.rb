class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    if value - Time.zone.now < -86400 || value - Time.zone.now > 31536000
      record.errors.add(:base, "Time must be within the next year.")
    # if user enters 4pm when it's already 5pm, add one day and continue
    elsif value - Time.zone.now < 0 && value - Time.zone.now > -86400
      record.update(attribute => value + 86400)
    end
  end
end
