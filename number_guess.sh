#!/bin/bash
RANDOM_NUMBER=$(( (RANDOM%1000)+1 ))
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

PLAYER_INFO=$($PSQL "SELECT games_played,min_guesses FROM \
players WHERE username='$USERNAME';")
if [[ -z $PLAYER_INFO ]]
then
  PLAYER_INSERT_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME');")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  BEST_GAME=9999
else
  echo $PLAYER_INFO | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
echo "Guess the secret number between 1 and 1000: "


GUESSES=0
USER_GUESS=-1
BEST_GAME=$($PSQL "SELECT min_guesses FROM players WHERE username='$USERNAME'")
while [[ $USER_GUESS != $RANDOM_NUMBER ]]
do
  read USER_GUESS
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    USER_GUESS=-1
  else
    GUESSES=$(( GUESSES+1 ))
    if [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      GAMES_PLAYED=$(( GAMES_PLAYED+1 ))
      
      if [[ $GUESSES -lt $BEST_GAME ]]
      then
        USER_UPDATE_RESULT=$($PSQL "UPDATE players SET min_guesses=$GUESSES, games_played=$GAMES_PLAYED \
        WHERE username='$USERNAME';")
      else
        USER_UPDATE_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED \
        WHERE username='$USERNAME';")
      fi
      
    fi
  fi
done

