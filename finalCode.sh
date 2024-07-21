

# variables initialization 

N=0
player1=""
player2=""
num_moves=0
current_player=0
current_mark=""
choice=""

# associative array works as a 2D array
declare -A grid

#================================================================

# Function to print the game grid.

printGrid() {

     clear # to clear the previous grid.

	if [ $choice == "y" ]; then
		N=$(( N + 1 ))
		fi

    echo "Game grid:"

    for ((i=0; i<N; i++)); do
        for ((j=0; j<N; j++)); do
            if [ $j -eq $((N - 1)) ]; then # to implement the grid correctly as required.
                echo -n " ${grid[$i,$j]} "
            else
                echo -n " ${grid[$i,$j]} |"  # Print the cell value followed by a space and a vertical bar
            fi
        done
        echo ""  # Move to the next line after each row
    done
}

# =================================================================

# Function to initialize the game when a new game is about to run.

initializeGrid() {

        for ((i=0; i<N; i++)); do
            for ((j=0; j<N; j++)); do
                grid[$i,$j]=" "  # Set each cell to empty
            done
        done
}

# =================================================================

# Function to load the grid from a file
loadFromFile() {
    echo "Enter the file name to load its grid:"
    read file_name

    # Read the file line by line and populate the grid
    if [ -e "$file_name" ]; then
        row_index=0
        while IFS= read -r line; do
            col_index=0
            IFS='|' read -ra cells <<<"$line"  # Split the line into an array of cells using '|' as delimiter
            for cell in "${cells[@]}"; do
                grid[$row_index,$col_index]="$cell"  # Assign each cell value to the grid
                ((col_index++))
            done
            ((row_index++))
        done < "$file_name"
        N=$((row_index))
    else
        echo "File not found"
        loadFromFile
        return
    fi
}

# ==================================================================

# Function to place marks in an empty cell (Move 1)
move1() {

    echo "Player $current_player's turn"
    echo "Enter the row and column numbers separated by a space to place your mark ('row column'): "
    read row col
    
    # making sure the values are valid.
    if [ $row -lt 1 ] || [ $row -gt $N ] || [ $col -lt 1 ] || [ $col -gt $N ]; then
        echo "Please enter valid row and column numbers."
        move_1  # recall the function
        return
    fi

    # Check if the cell is empty
    if [ "${grid[$((row - 1)),$((col - 1))]}" != " " ]; then
        echo "Cell is already occupied. Please choose an empty cell."
        move_1  
        return
    fi

    # Place the mark in the empty cell
    grid[$((row - 1)),$((col - 1))]=$current_mark
}

#----------------------------------------------------------------------------

# Function to handle move 2 (remove mark from an occupied cell)

move2() {

    echo "Player $current_player's turn"
    echo "Enter the row and column numbers separated by a space to remove the mark ('row column'): "
    read row col

    # check that the values are valid.
    if [ $row -lt 1 ] || [ $row -gt $N ] || [ $col -lt 1 ] || [ $col -gt $N ]; then
        echo "Invalid coordinates. Please enter valid row and column numbers."
        move2  
        return
    fi

    # Check if the cell is occupied
    if [ "${grid[$((row - 1)),$((col - 1))]}" == " " ]; then
        echo "Cell is already empty. Please choose an occupied cell."
        move2  
        return
    fi

    # Check if the mark in the cell belongs to the current player
    if [ $current_player -eq 1 ]; then
        if [ "${grid[$((row - 1)),$((col - 1))]}" != "X" ]; then # player1 has access to X mark only and so for player2 with O mark.

            echo "The mark is not yours to remove!"
            move2
            return
        fi
    elif [ $current_player -eq 2 ]; then
        if [ "${grid[$((row - 1)),$((col - 1))]}" != "O" ]; then
            echo "The mark is not yours to remove!"
            move2
            return
        fi
    fi

    # Remove the mark from the occupied cell
    grid[$((row - 1)),$((col - 1))]=" "
}
#---------------------------------------------------------

move3() {
    echo "Player $current_player's turn"
    echo "Enter the row numbers to exchange (format as: rxy, where x and y are row numbers): "
    read rowNums

	temp=$(echo $rowNums | cut -c1) # to check if entered the data correctly.
	if [ $temp != 'r' ]; then 
	echo "Please enter as specified!"
	move3
	return
	fi

    # get row numbers
    row1=$(echo $rowNums | cut -c2)
    row2=$(echo $rowNums | cut -c3)
    
    # check validity of data.
    if [ $row1 -lt 1 ] || [ $row1 -gt $N ] || [ $row2 -lt 1 ] || [ $row2 -gt $N ]; then
        echo "Invalid row numbers. Please enter valid row numbers."
        return
    fi

    row1=$((row1 - 1))  # to make sure that the index start from zero as the row numbers entered starts from 1 at least.
    row2=$((row2 - 1))  

    # exchanging rows
    for ((j=0; j<N; j++)); do
        temp_cell="${grid[$row1,$j]}"
        grid[$row1,$j]=${grid[$row2,$j]}
        grid[$row2,$j]=$temp_cell
    done
}

# ----------------------------------------------------------------------

# Function to exchange columns on the grid (Move 4)

move4() {

    echo "Player $current_player's turn"
    echo "Enter the column numbers to exchange (as format of :cxy, where x and y are column numbers): "
    read colNums

   	tmp=$(echo $col_nums | cut -c1) # to check if entered the data correctly.
        if [ $tmp != 'c' ]; then
        echo "Please enter as specified!"
        move4
        return
        fi

    # get column numbers
    col1=$(echo $colNums | cut -c2)
    col2=$(echo $colNums | cut -c3)
    
    # make sure data passed correctly.
    if [ $col1 -lt 1 ] || [ $col1 -gt $N ] || [ $col2 -lt 1 ] || [ $col2 -gt $N ]; then
        echo "Please enter valid column numbers."
        move4  
        return
    fi
	col1=$((col1 - 1)) # making sure index starts from 0 when exchanging.
	col2=$((col2 - 1))

    # exchange columns
    for ((i=0; i<N; i++)); do
        temp_cell="${grid[$i,$col1]}"
        grid[$i,$col1]=${grid[$i,$col2]}
        grid[$i,$col2]=$temp_cell
    done
}

# ----------------------------------------------------------------------

# Function to exchange positions of marks (Move 5)
move5() {
    echo "Player $current_player's turn"
    echo "Enter the positions to exchange marks (as 'exyuv', where e stands for exchange, x and y are player's credentials, u and v opponent's): "
    read positions

	var=$(echo $positions | cut -c1)
	if [ $var != 'e' ]; then
		echo "please check input data!"
		move5
		return
	fi

    # get positions
    player_row=$(echo $positions | cut -c2)
    player_col=$(echo $positions | cut -c3)
    opponent_row=$(echo $positions | cut -c4)
    opponent_col=$(echo $positions | cut -c5)
    
    # make sure are valid
    if [ $player_row -lt 1 ] || [ $player_row -gt $N ] || [ $player_col -lt 1 ] || [ $player_col -gt $N ] || [ $opponent_row -lt 1 ] || [ $opponent_row -gt $N ] || [ $opponent_col -lt 1 ] || [ $opponent_col -gt $N ]; then
        echo "Please enter valid positions."
        move5  
        return
    fi
	player_col=$((player_col - 1)) # also to make sure indexing starts at zero.
	player_row=$((player_row - 1))
	opponent_row=$((opponent_row - 1))
	opponent_col=$((opponent_col - 1))


    # exchange marks
    tempMark="${grid[$((player_row)),$((player_col))]}"
    grid[$((player_row)),$((player_col))]=${grid[$((opponent_row)),$((opponent_col))]}
    grid[$((opponent_row)),$((opponent_col))]=$tempMark
}

# ===============================================================================

# Function to calculate the score

score() {

    player1_score=0
    player2_score=0

    # Function to check for alignment of marks which is called after every case of possible score change.
    check_alignment() {

        local marks="$1" # local variable that is initialized according to what it has been passed by other functions.

        if echo "$marks" | grep -q "XXX"; then
            if [ $current_player -eq 1 ]; then 		# making sure that the score updates according to each player's mark and his moves.
                player1_score=$((player1_score + 2))
            else
                player2_score=$((player2_score - 3))
            fi
        elif echo "$marks" | grep -q "OOO"; then
            if [ $current_player -eq 1 ]; then
                player1_score=$((player1_score - 3))
            else
                player2_score=$((player2_score + 2))
            fi
        fi
    }

    # Check horizontal alignments
    for ((i=0; i<N; i++)); do
        row=""
        for ((j=0; j<N; j++)); do
            row+="${grid[$i,$j]}"
        done
        check_alignment "$row" # sends $row as parameter.
    done

    # Check vertical alignments
    for ((j=0; j<N; j++)); do
        col=""
        for ((i=0; i<N; i++)); do
            col+="${grid[$i,$j]}"
        done
        check_alignment "$col"
    done

    # Check diagonal alignments (from the top left to the bottom right.)
    diag1=""
    for ((i=0; i<N; i++)); do
        diag1+="${grid[$i,$i]}"
    done
    check_alignment "$diag1"

    # Check diagonal alignments (top-right to bottom-left)
    diag2=""
    for ((i=0; i<N; i++)); do
        diag2+="${grid[$i,$((N - i - 1))]}"
    done
    check_alignment "$diag2"

    # update score for different move types

    case $move_choice in
        2)  # Move 2 ( removing )
            if [ $current_player -eq 1 ]; then
                player1_score=$((player1_score + 1))
            else
                player2_score=$((player2_score + 1))
            fi
            ;;
        3|4)  # Move 3 or Move 4: exchanging either rows or columns.
            if [ $current_player -eq 1 ]; then
                player1_score=$((player1_score - 1))
            else
                player2_score=$((player2_score - 1))
            fi
            ;;
        5)  # Move 5: exchanging marks
            if [ $current_player -eq 1 ]; then
                player1_score=$((player1_score - 2))
            else
                player2_score=$((player2_score - 2))
            fi
            ;;
    esac

    # Display scores
    echo "Player 1 score: $player1_score"
    echo "Player 2 score: $player2_score"
}

# ======================================================================

# Main function to execute the game:

main() {


    echo "Enter Player 1's name:"
    read player1
    echo "Enter Player 2's name:"
    read player2

    echo "Enter the number of moves in which the game will end after:"
    read num_moves



	read -p "you want to load an existing file?(y/n)" choice

	# check whether to implement as a new game or load an existing one.

	if [ $choice == "y" ]; then
		loadFromFile

	elif [ $choice == "n" ]; then
		echo "Enter the dimensions of the grid (NxN, where N can be 3, 4, or 5):"
        	read N
		if [ $N -lt 3 ] || [ $N -gt 5 ]; then
   	     echo "Please insert valid dimensions!"
		main
   	     return
  		fi

		initializeGrid
		else
		echo "Please answer as a y/n only "
		main
		return
	fi

    # Set current player and mark
    current_player=1
    current_mark="X"


    while true; do
        # display the grid

        printGrid

        # ask for player move
        echo "Player $current_player's turn"
        echo "Choose your move:"
        echo "1. Place mark in an empty cell"
        echo "2. Remove mark from an occupied cell"
        echo "3. Exchange rows on the grid"
        echo "4. Exchange columns on the grid"
        echo "5. Exchange positions of marks"
       		 read move_choice

        # Handle different move types
        case $move_choice in
            1) move1 ;;
            2) move2 ;;
            3) move3 ;;
            4) move4 ;;
            5) move5 ;;
            *) echo " Please choose a valid move." ;;
        esac

        score # score function call.

        # Check if the moves are not exceeded.
        if [ $num_moves -eq 0 ]; then
            echo "Game over! Maximum number of moves reached."
            break
        fi

        # decrease number of moves after each loop
        num_moves=$((num_moves - 1))

        # switch players
        if [ $current_player -eq 1 ]; then
            current_player=2
            current_mark="O"
        else
            current_player=1
            current_mark="X"
        fi
    done
}

# ============================================================

# calling main to launch the game!

	main

