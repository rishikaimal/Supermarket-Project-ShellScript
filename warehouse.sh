#!/bin/bash
inv="database.txt"

function new_item()
{
	echo "Enter HSN Code:"
	read hsn
	echo "Enter Product Description:"
	read desc
	echo "Enter Quantity:"
	read quan
	echo "Enter MRP:"
	read mrp
	
	echo "$hsn $desc $quan $mrp" >> "$inv"
    	echo "Item added successfully."
}
	
function update_item()
{
	echo "Enter HSN Code to update:"
	read update_hsn
	
	if grep -q "$update_hsn" "$inv"; then
		echo "Item Found.\nDescription: $desc\n"
		echo "Enter new Description:"
		read new_desc
		echo "Enter new Quantity:"
		read new_quan
		echo "Enter new MRP:"
		read new_mrp



		
		echo "Item updated successfully.\n"
		
	else
	echo "HSN Code not found in inventory.\n"
	fi
}
	

	
function disp_item()
{ 
	echo -e "\n----------------Inventory items----------------\n"
	cat "$inv"
	echo -e "\n-----------------------------------------------\n"
}



while true
do
	echo -ne "Enter your choice: \n1.New Item\n2.Update Item\n3.Display Item\n4.Exit\n->"
	read choice

	case $choice in
		1) new_item;;
		2) update_item;;
		3) disp_item;;
		4) exit 0 ;;
		*) echo "Enter valid choice from 1 to 5.\n";;
	esac
done

