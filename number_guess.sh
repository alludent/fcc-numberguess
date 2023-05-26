#! /bin/bash
PSQL="psql -U freecodecamp -d users --no-align -t -c"

GAME_LOOP() {
  read GUESS  
  guess_cnt=$(( $guess_cnt + 1 ))

  # NOT AN INT
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GAME_LOOP
  fi

  # GUESS CORRECTLY
  if (( $GUESS == $random ))
  then
    # insert the game1
    # increment num games played
    games_played_query=$(( $games_played_query + 1 ))
    # update lowest guesses
    if (( $guess_cnt < $lowest_guesses_query ))
    then 
      lowest_guesses_query=$guess_cnt
    fi
    $($PSQL "UPDATE users SET games_played=$games_played_query, lowest_guesses=$lowest_guesses_query WHERE username='$USERNAME'" > /dev/null)
    echo "You guessed it in $guess_cnt tries. The secret number was $random. Nice job!"
    return
  # LESS THAN SECRET
  elif (( $GUESS > $random ))
  then
    echo "It's lower than that, guess again:"
    GAME_LOOP
  # GREATER THAN SECRET
  else
    echo "It's higher than that, guess again:"
    GAME_LOOP
  fi


}

echo "Enter your username: "
read USERNAME

random=$(( 1 + RANDOM % 1000 ))
guess_cnt=0

NAMEFOUND=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $NAMEFOUND ]] 
then
  # not found
  games_played_query=0
  lowest_guesses_query=1000
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $($PSQL "INSERT INTO users (username, lowest_guesses) VALUES ('$USERNAME', 1000)" > /dev/null)
  echo "Guess the secret number between 1 and 1000:"
  GAME_LOOP
else
  # found
  games_played_query=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  lowest_guesses_query=$($PSQL "SELECT lowest_guesses FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $games_played_query games, and your best game took $lowest_guesses_query guesses."
  echo "Guess the secret number between 1 and 1000:"
  GAME_LOOP 
fi