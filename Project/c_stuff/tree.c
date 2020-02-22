/*

C version of the tree project

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/**
 * Print a board.
*/
void printBoard(int boardSize, int board[][boardSize]) {
    int i = 0;
    int j = 0;

    printf("+-");
    for (i = 0; i < boardSize; i++) {
        printf("--");
    }
    printf("+\n");

    for (j = 0; j < boardSize; j++) {
        printf("| ");
       for (i = 0; i < boardSize; i++) {
            printf("%d ", board[j][i]);
        }
        printf("|\n");
    }

    printf("+-");
    for (i = 0; i < boardSize; i++) {
        printf("--");
    }
    printf("+\n");
}


/**
 * Populate the board with characters.
*/
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
                board[i][j] = 1;
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


/**
 * Main function
*/
int main(int argc, char** argv) {

    printf("******************\n**     Tents    **\n******************\n\n");

    // get the board size
    int boardSize = 0;
    scanf("%d", &boardSize);
    printf("%d\n", boardSize);

    if (boardSize < 2 || boardSize > 12) {
       printf("Invalid board size, Tents terminating\n");
       return 1; 
    }
    
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
        printf("%c", line[i]);
    }
    printf("\n");



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
        printf("%c", line[i]);
    }
    printf("\n");

    int invalidChars = populateBoard(boardSize, board);
    if (invalidChars != 0) {
        return 1;
    }


    /////////////////////////////////////////////////////////////////
    //////////////////// Print the Initial Board ////////////////////
    /////////////////////////////////////////////////////////////////

    printf("Initial Puzzle\n\n");
    printBoard(boardSize, board);

    return 0;

    //////////////////////////////////////////////////////////////////
    ////////////////////  Get the board chars  ///////////////////////
    //////////////////////////////////////////////////////////////////

    int j = 0;
    while (fgets(line, bufSize, stdin)) {

        // check that there are no extra characters
        if (strlen(line) - 1 != boardSize) { // -1 because of newline character
            printf("Ilegal board character, Tents terminating\n");
            return;
        }

        // parse the characters in the show
        i = 0;
        for (i = 0; i < strlen(line) - 1; i++) {
            if (line[i] != '.' || line[i] != 'T') {
                printf("Illegal board character, Tents terminating\n");
                return;
            }
            board[j][i] = line[i];
        }
    }
}
