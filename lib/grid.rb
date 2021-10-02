# frozen-string-literal: false

# class to represent grid of connect four game
class Grid
  attr_reader :rows, :columns, :grid

  def initialize(rows = 7, columns = 6)
    @rows = rows
    @columns = columns
    reset
  end

  def to_s
    "\n" << top << fields << bottom
  end

  def place(disk, column)
    return puts "Column #{column} is out of range" unless column.between?(0, rows - 1)

    if column_full?(column)
      puts "Column #{column} is full."
    else
      index = grid[column].rindex('◯')
      grid[column][index] = disk
    end
  end

  def reset
    @grid = Array.new(rows) { Array.new(columns, '◯') }
  end

  def column_full?(column)
    grid[column]&.none?('◯') || false
  end

  private

  def top
    ('║───' * rows) << "║\n"
  end

  def fields
    seperator = "\n╠" << rows.times.map { '═══' }.join('╬') << "╣\n"
    grid.transpose.map { |row| '║ ' << row.join(' ║ ') << ' ║' }.join(seperator)
  end

  def bottom
    "\n╚" << ('═══╩' * rows)[0..-2] << "╝\n" << "  #{(0...rows).map { |i| i }.join('   ')}\n"
  end
end
