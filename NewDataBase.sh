#!/bin/bash
PS3="Please enter your choice ^^ "

function CreateDatabase {
  echo "Enter database name"
  read db
 
 #checking not entered a null 
  if [ "$db" != "" ]
  then
        findRes=`find -name $db 2>>/dev/null`

    if [ "./$db" = "$findRes" ]
    then echo "this database already exists "
    else
    mkdir $db
    echo " database is created successfully, your new database is" $db
    fi
  else echo "Enter a proper name for the database"
  fi


    # if [ -d ./datab/"$db" ]
    # then
    #   ### Take action if $c exists ###
    #   echo $db "Database already exist :"
    # else
    #   ###  Control will jump here if $c does NOT exists ###
    # mkdir $db
    # chmod 777  $db
    # cp -r $db ./datab
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
    echo "Enter the table name"
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

        if [ $tisExist -ne 1 ]
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
                            header=$fieldN$fieldSep
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
                                header=$header$fieldN
                            else
                                header=$header$fieldN$fieldSep
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
                    echo $header >> $t
                    echo "$t table is created successfully"
                 
                    # assign empty value to header variable to hold the new table meta-data
                    header="" 
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
      listing=`ls -Al | grep ^- | wc -l`
      
      if [ $listing -eq 0 ]
          then echo "No tables found"
      else ls -p | grep -v /
      fi

}

function DropTable {
    echo -e "Your current tables are : \n "
    listTables
    echo "Choose the table name you want to drop ^^: "
    read dt
    # rm -R ./$udb/$dt
    # echo " Droped" $dt

      isExistdrop=0

      dropT_arr=(`ls -Al | grep ^-`)
      
      for i in $(seq ${#dropT_arr[@]})
      do  
          if [ "${dropT_arr[i-1]}" = "$dt" ]
          then
              isExistdrop=1
          fi
      done

      if [ $isExistdrop -eq 1 ]
      then
          rm $dt 
          echo "$dt table is dropped successfully"
      else
          echo "This table doesn't exist"
      fi
      
}

function InsertIntoTable {
    echo -e "Your current tables are: \n "
    listTables 
    echo -e "please choose the table you want to insert into: \n "
    read TableName

    # flags for validation
    isExisted_insert=0
    notValidInsertion=0

    InsertT_arr=(`ls -Al | grep ^-`)

    for i in $(seq 1 ${#InsertT_arr[@]})
    do  
        if [ "${InsertT_arr[i-1]}" = "$TableName" ]
        then 
            isExisted_insert=1
        fi
    done

    if [ $isExisted_insert -eq 1 ]
    then
        columnsNo=$(awk 'BEGIN{FS="|"}{
            if(NR == 1)
            print NF
        }' $TableName)
        #no. of rec first line then print no. of fields how many columns  
        
        fieldSep="|"

        for i in $(seq $columnsNo)
        do  
            fieldName=$(awk 'BEGIN{FS="|"}{if(NR == 1) print $'$i'}' $TableName)

            if [ $i -eq 1 ]
            then
                echo "Enter the value of $fieldName field:"
                read field
                pK=$field
                # rg1='[-]*'
                # rg2='[\!@#$%^&()-+=|\["\}\{\]/?><:;\.,`~ ]*'

                # if [[ "$pK"!= "$rg1"  ||  "$pK"!= "$rg2"  ||  "$pK"!= ""  ||  "$pK"!= ["'"] ]]
                
                if [ "$pK" != "" ]
                then

                    if [ "$pK" = "`awk -F "|" '{NF=1; print $'$i'}' $TableName | grep "\b$pK\b"`" ]
                    then
                        echo "This Primary key already exists,It has to be not repeated 'unique '"
                        notValidInsertion=1
                        break
                    else
                        record=$field$fieldSep
                        continue
                    fi
                else
                    echo "The primary key can't be null"
                    notValidInsertion=1
                    break
                fi
            else
                echo "Enter the value of $fieldName field:"
                read field
            fi
            # check if the loop is the last one to prevent the concatenation of separator
            if [ $i -eq $columnsNo ]
            then
                record=$record$field
            else
                record=$record$field$fieldSep  
            fi 
        done

        if [ $notValidInsertion -ne 1 ]
        then
            echo $record >> $TableName 
            echo "Insertion Done"

            #assign empty value to record variable to hold the new insertion
            record="" 
        else
            echo "Insertion Error"
        fi
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
  echo -e "These are your databases ^^ : \n   "
  ListDatabase  
  echo "Choose the database you want to connect with ^^ "
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
  echo -e "Your databases are : \n "
  ListDatabase
  echo "choose database name you want to drop without the '/' "
  read ddb 
  
  findDdb=`find -name $ddb 2>>/dev/null`

    if [ "./$ddb" = "$findDdb" ] 
        then
        echo "type yes to confirm droping or no to cancel"
        rm -Ir $ddb 
        echo "you have dropped $ddb"
        
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

# change directory to the DB-engine folder, once the script runs
cd DB-engine

# calling the main menu function once the script runs 
MainMenu




