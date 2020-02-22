/**
 * C representation of the tents program.
 * 
 * Author : Sarah Strickman
**/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// constants
int EMPTY_SPACE = 0;    // nothing is here
int TENT_UP = 1;        // the tree is above the tent
int TENT_LEFT = 2;      // the tree is to the left of the tent
int TENT_RIGHT = 3;     // the tree is to the right of the tent
int TENT_BOT = 4;       // the tree is below the tent
int TREE_EMPTY = 5;     // tree without tent attached
int TREE_FULL = 6;      // tree with tent attached

/**
 * Prints the board.
**/
void printBoard(int boardSize, int board[][boardSize], int rowMax[], int colMax[]) {
    int i = 0;
    int j = 0;

    // print top border
    printf("+-");
    for (i = 0; i < boardSize; i++) {
        printf("--");
    }
    printf("+\n");

    // print board side borders, contents, and col capacities
    int curr;
    for (j = 0; j < boardSize; j++) {
        printf("| ");
        for (i = 0; i < boardSize; i++) {
            curr = board[i][j];
            if (curr == 0) {
                printf(". ");
            }
            else if (curr >= 1 || curr <= 4) {
                printf("A ");
            }
            else if (curr == 5 || curr == 6) {
                printf("T ");
            }
        }
        printf("| %d\n", rowMax[j]);
    }

    // print bottom border
    printf("+-");
    for (i = 0; i < boardSize; i++) {
        printf("--");
    }
    printf("+\n");

    // print bottom capacity numbers
    printf(" ");
    for (i = 0; i < boardSize; i++) {
        printf(" %d", colMax[i]);
    }
    printf("\n");
}

/**
 * populate the board with things from stdin
**/
int populateBoard(int boardSize, int board[][boardSize]) {
    int i = 0;
    int j = 0;

    int bufSize = 20;
    char line[bufSize];

    while (fgets(line, bufSize, stdin)) {

        // check that there are no extra characters
        if (strlen(line) - 1 != boardSize) { // -1 because of newline character
            printf("Illegal board character, Tents terminating\n");
            return 1;
        }

        // parse the characters in the line
        i = 0;
        for (i = 0; i < strlen(line) - 1; i++) {
            if (line[i] != '.' && line[i] != 'T') {
                printf("Illegal board character, Tents terminating\n");
                return 1;
            }
            int num = -1;
            if (line[i] == '.') {
                board[i][j] = 0;
            }
            else if (line[i] == 'T') {
                board[i][j] = 5;
            }
            else {
                printf("Illegal board character, Tents terminating\n");
                return 1;
            }
        }
        j++;
    }
    return 0;
}


int main(int argc, char** argv) {

    // get the board size
    int boardSize = 0;
    scanf("%d", &boardSize);

    // check for invalid board size
    if (boardSize < 2 || boardSize > 12) {
       printf("Invalid board size, Tents terminating\n");
       return 1; 
    }
    
    // used to check for row and col sizes
    int halfsize = (boardSize + 1) / 2;

    // get newline character
    char c = getchar();
    
    // create the board
    int board[boardSize][boardSize];
    int rowMax[boardSize];
    int colMax[boardSize];

    int bufSize = 20;
    char line[bufSize]; 

    //////////////////////////////////////////////////////////////////
    ////////////////////  Get the rows ints  /////////////////////////
    //////////////////////////////////////////////////////////////////

    // get next line
    fgets(line, bufSize, stdin); 

    // handle for a sum > 10
    if (strlen(line) - 1 != boardSize) { // -1 because of newline character
        printf("Invalid sum, Tents terminating\n");
        return 1;
    }

    int i = 0;

    // Now we know that none of them are > 9. Check the numbers to make sure
    // that all digits are valid.
    for (i = 0; i < strlen(line) - 1; i++) {
        int c = line[i] - '0';
        if (c < 0 || c > halfsize) {
            printf("Invalid sum, Tents terminating\n");
            return 1;
        }
        rowMax[i] = c;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////  Get the cols ints  ////////////////////////
    //////////////////////////////////////////////////////////////////
    
    // get next line
    fgets(line, bufSize, stdin); 

    // handle for a sum > 10
    if (strlen(line) - 1 != boardSize) { // -1 because of newline character
        printf("Invalid sum, Tents terminating\n");
        return 1;
    }
    
    i = 0;

    // Now we know that none of them are > 9. Check the numbers to make sure
    // that all digits are valid.
    for (i = 0; i < strlen(line) - 1; i++) {
        int c = line[i] - '0';
        if (c < 0 || c > halfsize) {
            printf("Invalid sum, Tents terminating\n");
            return 1;
        }
        colMax[i] = c;
    }

    int invalidChars = populateBoard(boardSize, board);
    if (invalidChars != 0) {
        return 1;
    }


    /////////////////////////////////////////////////////////////////
    //////////////////// Print the Initial Board ////////////////////
    /////////////////////////////////////////////////////////////////

    printf("******************\n**     Tents    **\n******************\n\n");

    printf("Initial Puzzle\n\n");
    printBoard(boardSize, board, rowMax, colMax);

    return 0;
}
