class MemoryPolicy < BlockRecordPolicy
  def show?
    if user.try(:admin?)
      true
    else
      record.public?
    end
  end
end
