#!/bin/bash
PS3="Enter your choice please :)"

function CreateDatabase {
  echo "Enter database name"
  read db 
  #checking not entered a null 

  if [ "$db" != "" ]
  then
    if [ -d ./datab/"$db" ]
    then
      ### Take action if $c exists ###
      echo $db "Database already exist :("
    else
      ###  Control will jump here if $c does NOT exists ###
    mkdir $db
    chmod 777  $db
    cp -r $db ./datab
    echo " database is created successfully, your new database is" $db
    fi
  else echo "Enter a proper name for the database"
      fi
  
}

function ListDatabase {
  #ls -a ./datab
  dbls=`ls -Al | grep ^d | wc -l`    
      if [ $dbls -eq 0 ]
          then 
              echo "No Databases found"
      else
          ls -d */
      fi
}

function CreateTable {
    echo "Enter table name"
      read t
        if [ "$t" != "" ]
    then

        tisExist=0
        tnotValid=0


        createT_arr=(`ls -Al | grep ^-`)

        for i in $(seq 1 ${#createT_arr[@]})
        do  
            if [ "${createT_arr[i-1]}" = "$t" ]
            then 
                echo "This table name already exists"
                tisExist=1
            fi
        done

        if [ $isExist -ne 1 ]
        then
            echo "Enter the number of columns:"
            read no_cols

            if [[ "$no_cols" != "" && $no_cols =~ ^[0-9]+$ ]]
            then
                fieldSep="|"

                for i in $(seq $no_cols)
                do  
                    if [ $i -eq 1 ]
                    then 
                        echo "Enter the name of Primary Key (column $i):"
                        read fieldN

                        # check if input has value 
                        if [ "$fieldN" != "" ]
                        then
                            # concatenate the first field with the separator
                            fieldFullName=$fieldN$fieldSep
                        else 
                            tnotValid=1
                            break
                        fi

                    else
                        echo "Enter the name of column number $i:"
                        read fieldN


                        # check if input has value 
                        if [ "$fieldN" != "" ]
                        then
                            # check if the loop is the last one to prevent the concatenation of separator
                            if [ $i -eq $no_cols ]
                            then
                                fieldFullName=$fieldFullName$fieldN
                            else
                                fieldFullName=$fieldFullName$fieldN$fieldSep
                            fi
                        else 
                            tnotValid=1
                            break
                        fi
                    fi
                done

                # if we get valid inputs so create table
                if [ $tnotValid -ne 1 ]
                then
                    touch $t
                    echo $fieldFullName >> $t
                    echo "$t table is created successfully"
                 
                    # assign empty value to fieldFullName variable to hold the new table meta-data
                    fieldFullName="" 
                else
                    echo "Columns' names can't be null values"
                fi
            else 
                echo "Enter a proper number of columns"
            fi
        fi
    else
        echo "Please enter a proper name for the table"
    fi

}

function listTables {
     #ls -a ./$udb
      #m7tagen yb2u functions 3shan variable w if 
      listing=`ls -Al | grep ^- | wc -l`
      
      if [ $listing -eq 0 ]
          then echo "No tables found"
      else ls -p | grep -v /
      fi

}

function DropTable {
    echo "Enter table name you want to drop"
    read dt
    # rm -R ./$udb/$dt
    # echo " Droped" $dt

      isExist=0

      dropT_arr=(`ls -Al | grep ^-`)
      
      for i in $(seq ${#dropT_arr[@]})
      do  
          if [ "${dropT_arr[i-1]}" = "$dt" ]
          then
              isExisted_drop=1
          fi
      done

      if [ $isExisted -eq 1 ]
      then
          rm $dt 
          echo "$dt table is dropped successfully"
      else
          echo "This table doesn't exist"
      fi
      
}

function ConnectMenu {
    echo "Successfully connected to $DatabaseConnect database"
    echo "Connect Menu:"
    select choice in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Go to Main Menu"
    do    
    case $choice in
        "Create Table" ) CreateTable ;;
        "List Tables" ) listTables ;;
        "Drop Table" ) DropTable ;;
        "Insert into Table" ) InsertIntoTable;;
        "Select From Table" ) SelectFromTable ;;
        "Delete From Table" ) DeleteFromTable ;;
        # to go back to previous menu (disconnect from the current database): change directory backward one step
        "Go to Main Menu" ) cd .. ; MainMenu ;;
        * ) echo $REPLY is not one of the choices ;;
    esac
    done
}

function ConnectDatabase {
  echo "Enter database name you want to connect with ^^ "
  read udb 
  findUdb=`find -name $udb 2>>/dev/null`

    if [ "./$udb" = "$findUdb" ] 
        then 
            cd $udb
            ConnectMenu
    else
        echo "This database doesn't exist"
    fi

}

function DropDatabase {
  echo "Enter database name you want to drop"
  read ddb
  findDdb=`find -name $ddb 2>>/dev/null`

    if [ "./$ddb" = "$findDdb" ] 
        then
        echo "print yes or no to confirm droping"
        rm -Ir $ddb  
    else
        echo "This database doesn't exist"
    fi

  # rm -R ./datab/$ddb
  # echo " Droped" $ddb

}

function MainMenu {
    echo "Main Menu:"
    select choice in "Create Database" "List Databases" "Connect to Databases" "Drop Database" "Exit"
    do    
    case $choice in
        "Create Database" ) CreateDatabase ;;
        "List Databases" ) ListDatabase ;;
        "Connect to Databases" ) ConnectDatabase ;;
        "Drop Database" ) DropDatabase ;;
        "Exit" ) exit ;;
        * ) echo $REPLY is not one of the choices ;;
    esac
    done
}

# change directory to the datab folder, once the script runs
cd datab

# calling the main menu function once the script runs 
MainMenu




