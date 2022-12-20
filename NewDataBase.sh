#!/bin/bash
PS3="Enter your chois please :)"
select choice in "Create Database" " List Database" "Drop Database" "Connect To Database"  Exit
do
case $choice in 
"Create Database") 
echo "Enter database name"
read db 
if [ -d ./datab/"$db" ]
 then
  ### Take action if $c exists ###
  echo $db "Database already exist :("
else
  ###  Control will jump here if $c does NOT exists ###
mkdir $db
chmod 777  $db
cp -r $db ./datab
echo "your new database is" $db
fi
;; 
" List Database") 
ls -a ./datab
;; 
"Drop Database")
echo "Enter database name to drop"
read ddb
rm -R ./datab/$ddb
echo " Droped" $ddb
 ;; 
###############tables into this
"Connect To Database") 
echo "Enter database name"
read udb 
if [ -d ./datab/"$udb" ]
 then
  ### Take action if $c exist ###
cd ./$udb
echo "Now you're using" $udb
##################################
select choice in "Create table" " List tables" "Drop table" Exit
do
case $choice in 
"Create table") 
echo "Enter table name"
read t
if [ -d ./"$t" ]
 then
  ### Take action if $c exists ###
  echo $t "Table already exist :("
else
  ###  Control will jump here if $c does NOT exists ###
mkdir ./$t
chmod 777  $t
cp -r $t ./$udb
echo "your new table is" $t
fi
;; 
" List tables") 
ls -a ./$udb
;; 
"Drop table")
echo "Enter table name to drop"
read dt
rm -R ./$udb/$dt
echo " Droped" $dt
 ;; 
#"Alter table") 
#echo "Enter database name"
#read u 
#if [ -d ./datab/"$u" ]
 #then
  ### Take action if $c exist ###
#cd ./$u
#echo "Now you're using" $u

#else
  ###  Control will jump here if $c not exist ###
 # echo $u "Database not exist :("
#fi
#;;
Exit) 
cd ..
echo " 1) Create Database  4) Connect To Database
2) List Database   5) Exit
3) Drop Database"
break
 ;; 
*) echo $REPLY "is not one of the choices :( " 
;; 
esac 
done
#######################################

else
  ###  Control will jump here if $c not exist ###
  echo $udb "Database not exist :("
fi
;;
Exit) break
 ;; 
*) echo $REPLY "is not one of the choices :( " 
;; 
esac 
done
