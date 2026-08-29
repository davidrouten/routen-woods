class SortParam
  attr_reader :column, :direction

  def initialize(param)
    raw = param.to_s
    @desc = raw.start_with?("-")
    @column = raw.delete_prefix("-").presence
    @direction = @desc ? "desc" : "asc"
  end

  def desc?
    @desc
  end

  def active?
    @column.present?
  end
end
