#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# EMPTY ROWS IN TABLES OF DATABASE
RESULTS_TRUNCATE_TABLE=$($PSQL "TRUNCATE TABLE games, teams;")
if [[ $RESULTS_TRUNCATE_TABLE == 'TRUNCATE TABLE' ]]
then
  echo Table data successfully erasedd
fi

# LOOP THROUGH DATA IN CSV FILE
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # SKIP HEADER ROW
  if [[ $year != 'year' ]]
  # For each entry in CSV file
  then
   
    # Get Winner Id from teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
    # IF WINNER not in teams table
    if [[ -z $WINNER_ID ]]
    then
      # Insert winner into teams table
      RESULTS_INSERT_WINNER=$($PSQL "INSERT INTO teams(name) values('$winner');")
      if [[ $RESULTS_INSERT_WINNER == 'INSERT 0 1' ]]
      then
        echo Successfully inserted: $winner
      fi
      # Get Winner Id from teams table
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
    fi

    # Get Opponenet ID from teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
    # IF OPPONENT not in teams table
    if [[ -z $OPPONENT_ID ]]
    then
      # Insert Opponent into teams table
      RESULTS_INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) values('$opponent');")
      if [[ $RESULTS_INSERT_OPPONENT == 'INSERT 0 1' ]]
      then
        echo Successfully inserted: $opponent
      fi
      # Get Opponent Id from teams table
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
    fi

    #Insert year, round, winner_id, opponent_id, winner_goals, opponent_goals into games table
    RESULTS_INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);")
    if [[ $RESULTS_INSERT_GAME == 'INSERT 0 1' ]]
    then
      echo Succcessfully inserted: $year, $round, $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals
    fi
  fi
done
