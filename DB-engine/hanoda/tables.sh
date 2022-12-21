
function CreateTable {
    echo "Enter the Table Name:"
    read TableName
    # check if the input value exists or null
    if [ "$TableName" != "" ]
    then
        # flags for validation
        isExist=0
        notValidTable=0

        # array carries all tables in database
        # listing only tables (files) inside array
        createT_arr=(`ls -Al | grep ^-`)

        # looping on array elements to check if there is a table exists with the same name
        for i in $(seq 1 ${#createT_arr[@]})
        do  
            if [ "${createT_arr[i-1]}" = "$TableName" ]
            then 
                echo "This table name already exists"
                isExist=1
            fi
        done

        if [ $isExist -ne 1 ]
        then
            echo "Enter the number of columns:"
            read no_cols

            # check if the input has value and is a number 
            if [[ "$no_cols" != "" && $no_cols =~ ^[0-9]+$ ]]
            then
                # define our fields/columns separator
                colSep="|"

                for i in $(seq $no_cols)
                do  
                    # check if the we are looping on the first column to assign it as a primary key
                    if [ $i -eq 1 ]
                    then 
                        echo "Enter the name of Primary Key (column $i):"
                        read colName

                        # check if input has value 
                        if [ "$colName" != "" ]
                        then
                            # concatenate the first field with the separator
                            header=$colName$colSep
                        else 
                            notValidTable=1
                            break
                        fi

                    else
                        echo "Enter the name of column number $i:"
                        read colName

                        # check if input has value 
                        if [ "$colName" != "" ]
                        then
                            # check if the loop is the last one to prevent the concatenation of separator
                            if [ $i -eq $no_cols ]
                            then
                                header=$header$colName
                            else
                                header=$header$colName$colSep
                            fi
                        else 
                            notValidTable=1
                            break
                        fi
                    fi
                done

                # if we get valid inputs so create table
                if [ $notValidTable -ne 1 ]
                then
                    touch $TableName
                    echo $header >> $TableName
                    echo "$TableName table is created successfully"
                 
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
    # ls for listing files/directoreis
    # -A : almost all for ignoring . and ..
    # -l : long listing
    # grep only files (listed files begin with -)
    # wc -l : count output lines of grep

    listing=`ls -Al | grep ^- | wc -l`
    
    if [ $listing -eq 0 ]
        then echo "No tables found"
    # -p : append / indicator to directories
    # then grep the inverse (-v) of any thing have "/" (only files)
    else ls -p | grep -v /
    fi
}

function DropTable {
    echo "Enter the table you want to drop:"
    read TableName
    
    isExisted_drop=0

    # array carries all tables in database
    # listing only tables (files) inside array
    dropT_arr=(`ls -Al | grep ^-`)
    
    # looping on array elements to check if there is a table exists with the input name
    for i in $(seq ${#dropT_arr[@]})
    do  
        if [ "${dropT_arr[i-1]}" = "$TableName" ]
        then
            isExisted_drop=1
        fi
    done

    if [ $isExisted_drop -eq 1 ]
    then
        rm $TableName 
        echo "$TableName table is dropped successfully"
    else
        echo "This table doesn't exist"
    fi
}

function InsertIntoTable {
    echo "Enter the table you want to insert into:"
    read TableName

    # flags for validation
    isExisted_insert=0
    notValidInsertion=0

    # array carries all tables in database
    # listing only tables (files) inside array
    InsertT_arr=(`ls -Al | grep ^-`)

    # looping on array elements to check if there is a table exists with the input name
    for i in $(seq 1 ${#InsertT_arr[@]})
    do  
        if [ "${InsertT_arr[i-1]}" = "$TableName" ]
        then 
            isExisted_insert=1
        fi
    done

    if [ $isExisted_insert -eq 1 ]
    then

        # get the number of columns of the table
        columnsNo=$(awk 'BEGIN{FS="|"}{
            if(NR == 1)
            print NF
        }' $TableName)
        
        colsep="|"

        # loop to read the data to be inserted one by one
        for i in $(seq $columnsNo)
        do  
            # get the fields names from the table
            fieldName=$(awk 'BEGIN{FS="|"}{if(NR == 1) print $'$i'}' $TableName)

            # check if we are looping on the primary key field 
            if [ $i -eq 1 ]
            then
                echo "Enter the value of $fieldName field:"
                read field
                pK=$field
                
                # check if the inserted primary key is not null
                if [ "$pK" != "" ]
                then
                    # check if the inserted primary key exists in our table by :
                    # 1) getting the first column of table (pk) using awk ($1) 
                    # 2) grep on the output of awk to find if this pk exists
                    # 3) adding \b as borders to match the exact inserted pk
                    if [ "$pK" = "`awk -F "|" '{NF=1; print $'$i'}' $TableName | grep "\b$pK\b"`" ]
                    then
                        echo "This Primary key already exists"
                        notValidInsertion=1
                        break
                    else
                        # concatenate the first field (pk) with separator
                        record=$field$colsep
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
                record=$record$field$colsep  
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

function SelectFromTable {
    echo "Enter the table you want to select from:"
    read TableName

    # flag for validation
    isExisted_select=0

    # array carries all tables in database
    # listing only tables (files) inside array
    selectT_arr=(`ls -Al | grep ^-`)
    
    # looping on array elements to check if there is a table exists with the input name
    for i in $(seq 1 ${#selectT_arr[@]})
    do  
        if [ "${selectT_arr[i-1]}" = "$TableName" ]
        then 
            isExisted_select=1
        fi
    done

    if [ $isExisted_select -eq 1 ]
    then
        echo "Choose whether select all or using the table's primary key"
        select choice in "All" "Using PK" "Back to Connect Menu"
        do    
        case $choice in
            # using sed print all inside this table
            "All" ) sed '/*/p' $TableName ;;
            "Using PK" ) echo "Enter the Primary Key value to select your record"
                        read pk_value
                        
                        # another way to check if the input is null or has value 
                        if [ ! -z $pk_value ] 
                        then
                            # check if the inserted primary key exists in our table by :
                            # 1) getting the first column of table (pk) using awk ($1) 
                            # 2) grep on the output of awk to find if this pk exists
                            # 3) adding \b as borders to match the exact inserted pk
                            if [ "$pk_value" = "`awk -F "|" '{NF=1; print $1}' $TableName | grep "\b$pk_value\b"`" ]
                            then
                                # get the record number using awk 
                                NR=`awk 'BEGIN{FS="|"}{if ($1=="'$pk_value'") print NR}' $TableName`
                                
                                # get the table meta-data (header)
                                echo `awk 'BEGIN{FS="|"}{if (NR==1) print $0}' $TableName`
                                
                                # print the record selected using sed
                                # -n : prevent the default of sed command to avoid unwanted records and duplication 
                                sed -n ""$NR"p" $TableName

                            else
                                echo "This Primary key doesn't exist"
                            fi
                        else
                            echo "The primary key can't be null"
                        fi    
            ;;
            "Back to Connect Menu" ) ConnectMenu ;;
            * ) echo $REPLY is not one of the choices ;;
        esac
        done
    else
        echo "This table doesn't exist"
    fi
}

function DeleteFromTable {
    echo "Enter the table name you want to delete from:"
    read TableName

    # flag for validation
    isExisted_delete=0

    # array carries all tables in database
    # listing only tables (files) inside array
    deleteT_arr=(`ls -Al | grep ^-`)

    # looping on array elements to check if there is a table exists with the input name
    for i in $(seq 1 ${#deleteT_arr[@]})
    do  
        if [ "${deleteT_arr[i-1]}" = "$TableName" ]
        then 
            isExisted_delete=1
        fi
    done

    if [ $isExisted_delete -eq 1 ]
    then
        echo "Enter the primary key value of the record you want to delete:"
        read pK

        # check if the input is null or has value 
        if [ ! -z $pK ]
        then
            # check if the inserted primary key exists in our table by :
            # 1) getting the first column of table (pk) using awk ($1) 
            # 2) grep on the output of awk to find if this pk exists
            # 3) adding \b as borders to match the exact inserted pk
            if [ "$pK" = "`awk -F "|" '{NF=1; print $1}' $TableName | grep "\b$pK\b"`" ]
            then
                
                # get the record number using awk 
                NR=`awk 'BEGIN{FS="|"}{if ($1=="'$pK'") print NR}' $TableName`
                
                # delete the selected record using sed
                # -i : to edit files in place 
                sed -i ''$NR'd' $TableName
                
                echo "Record deleted successfully"
            else
                echo "This Primary key doesn't exist"
            fi
        else
            echo "The primary key can't be null"
        fi    
    else
        echo "This table doesn't exist"
    fi
}

