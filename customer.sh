#!bin/bash
inv="database.txt"
sales="sales.txt"
custSales="CustomerSales.txt"
tempsales="saletemp.txt"

sales="sales.txt"
custSales="CustomerSales.txt"

if [ ! -f "$sales" ]; then
    touch "$sales"
fi

if [ ! -f "$custSales" ]; then
    touch "$custSales"
fi


record_sales() {
    inHSN="$1"
    new_quan="$2"
    description=$(awk -v inHSN="$inHSN" '$1 == inHSN {print $2}' "$inv")

    if [ -n "$description" ]; then
        # Check if the HSN already exists in the sales file
        if grep -q "$inHSN" "$sales"; then
            # Update the existing entry
            awk -v inHSN="$inHSN" -v new_quan="$new_quan" '
                $1 == inHSN { $3 += new_quan; print $0; updated = 1; next }
                { print $0 }
                END { if (!updated) print inHSN, new_quan }
            ' "$sales" > temp_sales && mv temp_sales "$sales"
        else
            # Add a new entry
            echo "$inHSN $description $new_quan" >> "$sales"
        fi
    fi
}

record_custsales(){
	 inHSN="$1"
    new_quan="$2"
    description=$(awk -v inHSN="$inHSN" '$1 == inHSN {print $2}' "$inv")

    if [ -n "$description" ]; then
        echo "$inHSN $description $new_quan" >> "$custSales"
    fi
}


gen_bill() {
    inHSN="$1"
    new_quan="$2"

    while read -r tempHSN tempQuan; do
        if [[ $inHSN == $tempHSN ]]; then
			record_sales "$inHSN" "$new_quan"
			record_custsales "$inHSN" "$new_quan"
            subtract_quantity "$inHSN" "$tempQuan"
        fi
    done < "$tempsales"
	rm saletemp.txt


}

subtract_quantity() {
    local hsn="$1"
    local subtract_quan="$2"

    awk -v hsn="$hsn" -v subtract_quan="$subtract_quan" '
        $1 == hsn { $3 -= subtract_quan; if ($3 < 0) $3 = 0; print $0; next }
        { print $0 }
    ' "$inv" > temp_inv && mv temp_inv "$inv"
}

buy_item() {
    echo -e "Enter HSN code of the product: "
    read inHSN
    local description
    description=$(awk -v inHSN="$inHSN" '$1 == inHSN {print $2}' "$inv")

    if [ -n "$description" ]; then
        echo "Item found."
        echo "Product Description: $description"
        echo -e "Enter Quantity: "
        read inQuan

        echo -e "What do you want to do?\n1. Continue buying\n2. Edit Quantity\n3. Generate Bill\n4. Exit "
        read choice
        case $choice in
            1) echo "$inQuan $description added to cart."
			   echo "$(awk -v inHSN="$inHSN" '$1 == inHSN {print $1}' "$inv") $inQuan" >> "$tempsales"
               buy_item;;
            2) get_quantity;;
            3) echo "$(awk -v inHSN="$inHSN" '$1 == inHSN {print $1}' "$inv") $inQuan" >> "$tempsales"
			   gen_bill "$inHSN" "$inQuan";;
            4) exit 0;;
            *) echo "Enter valid input (1-4).";;
        esac
    else
        echo "No item with HSN code $inHSN found."
    fi
}



while true
do
	echo -e "1.Buy items\n2.Exit\nEnter your choice -> "
	read ch
	case $ch in
		1) echo -e "Enter your name: "
		read name
		echo -e "\n----------------------------\n$name's Bill:" >> "$custSales"
		buy_item;;
		2) exit 0;;
		*) echo "Enter valid choice (1-2)."
	esac

done
	
