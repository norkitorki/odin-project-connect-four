# frozen-string-literal: false

require_relative 'grid'

# class for a console game of Connect Four
class ConnectFour
  attr_reader :player1, :player2, :current_player, :grid_board

  PLAYER = Struct.new(:name, :disk)

  def initialize(player1 = 'Player1', player2 = 'Player2', grid = Grid.new(7, 6))
    @player1 = PLAYER.new(player1, "\e[0;31;49m●\e[0m")
    @player2 = PLAYER.new(player2, "\e[0;34;49m●\e[0m")
    @current_player = rand.round == 1 ? @player1 : @player2
    @grid_board = grid
  end

  def play
    loop do
      puts grid_board
      place(player_input)
      break post_game if game_over? || draw?

      swap_players
    end
  end

  def player_input
    puts "\n#{current_player.name}'s(#{current_player.disk}) turn. Please input a position:\n\n"
    valid_positions = valid_input_positions
    loop do
      input = user_input[/^[0-6]{1}$/]&.to_i
      return input if input && !grid_board.column_full?(input)

      puts 'Invalid input. Please input one of these positions: ' << valid_positions
    end
  end

  def place(position)
    grid_board.place(current_player.disk, position)
  end

  def swap_players
    @current_player = current_player == player1 ? player2 : player1
  end

  def post_game
    puts grid_board
    puts game_over? ? "\n#{current_player.name} has won the game!\n" : "\nThe game ended in a draw\n"
    puts "\nWould you like to play again? (y/n)"
    input = user_input.downcase until %w[y n].include?(input)
    return if input == 'n'

    grid_board.reset
    play
  end

  def user_input
    print '-> '
    gets.chomp
  end

  def game_over?
    vertical_match? || horizontal_match? || diagonal_match? ||
      diagonal_match?(grid_board.grid.reverse)
  end

  def draw?
    7.times { |i| return false unless grid_board.column_full?(i) }
    true
  end

  private

  def valid_input_positions
    7.times.map { |i| grid_board.column_full?(i) ? '' : i }.join(' ')
  end

  def vertical_match?(grid = grid_board.grid)
    grid.any? { |col| col.join.include?(current_player.disk * 4) }
  end

  def horizontal_match?
    vertical_match?(grid_board.grid.transpose)
  end

  def diagonal_match?(grid = grid_board.grid)
    7.times do |i|
      6.times do |y|
        next unless grid[i][y].include?('●')

        arr = 6.times.map { |j| grid[i + j]&.at(y + j) }
        return true if vertical_match?([arr])
      end
    end
    false
  end
end
