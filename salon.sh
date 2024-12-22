#!/bin/bash
PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU() {
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED 
  case $SERVICE_ID_SELECTED in
    1|2|3|4) BOOK_SERVICE $SERVICE_ID_SELECTED ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

BOOK_SERVICE() {
  SERVICE_ID=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
  
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE;
  
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")

  echo -e "\nWhat time would you like your $(REMOVE_SPACES $SERVICE_NAME), Fabio?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  
  if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $(REMOVE_SPACES $SERVICE_NAME) at $SERVICE_TIME, $(REMOVE_SPACES $CUSTOMER_NAME)."
  else
    ERROR
  fi
}

EXIT() {
  echo -e "\nWe hope to see you soon!"
}

ERROR() {
  echo -e "\nSorry, something went wrong. Please try again..."
}

REMOVE_SPACES() {
  echo "$1" | sed -r 's/^ *| *$//g'
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"

