#! /bin/sh

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
	echo "Illegal number of params"
	exit 1
fi

specs=$(lscpu)
hostname=$(hostname)

cpu_number=$(echo "$specs" | grep "^CPU(s):" | awk '{print $2}')
cpu_architecture=$(echo "$specs" | grep "^Architecture:" | awk '{print $2}')
cpu_model=$(echo "$specs" | grep "^Model name" | awk '{print $3,$4,$5,$6,$7}')
cpu_mhz=$(echo "$specs" | grep "^CPU MHz:" | awk '{print $3}')
l2_cache=$(echo "$specs" | grep "^L2 cache:" | awk '{print $3}' | sed 's/[^0-9]//g')
timestamp=$(vmstat -t | awk {'print $18 $19'} | tail -n1)

total_mem="(SELECT total_mem FROM host_info WHERE hostname LIKE '$hostname'%')";
id="(SELECT id FROM host_info WHERE hostname like '$hostname'%)";

insert_stmt="INSERT INTO host_info(id, hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, timestamp, total_mem) VALUES ($id, $hostname, $cpu_number, $cpu_architecture, $cpu_model, $cpu_mhz, $l2_cache, '$timestamp', $total_mem);

export PGPASSWORD=$psql_password

psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?
