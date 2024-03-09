#! /bin/bash

echo -e "\n~~~~ Salon Appointments ~~~\n"

PSQL=("psql -X --username=freecodecamp --dbname=salon --tuples-only -c")

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get availables services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  if [[ $AVAILABLE_SERVICES ]]
  then
    # display availables services
    echo -e "\n What service do you want today?\n"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED

    # check if is a valid input
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$  ]]
    then
      # return to main menu
      MAIN_MENU "Please select a valid option"
    else
      # check if service exists
      SERVICE_EXISTS=$($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ $SERVICE_EXISTS -eq 1 ]]; 
      then
        # Get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        # Get customer info
        echo -e "\nEnter your phone number:"
        read CUSTOMER_PHONE
        
        # Check if the client exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nEnter your name: " 
          read CUSTOMER_NAME

          # save new customer
          CUSTOMER_INSERT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          
          # get time for appointment
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          
          # insert appointment
          INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          
          # Confirmation message
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME  | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME  | sed -r 's/^ *| *$//g')."
        else
          # Get service name
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          # get time for appointment
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          
          # insert appointment
          INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

          # Confirmation message
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME  | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME  | sed -r 's/^ *| *$//g')."

        fi
      else
        MAIN_MENU "Service selected not available"
      fi # end service_exists
    fi # end service_id_selected
  else
    # Back to main menu if no exists the service
    MAIN_MENU "Please select a valid service"
  fi #end if Available_services
}

MAIN_MENU